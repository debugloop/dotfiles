import * as net from "node:net";
import { pipeline } from "node:stream";

import { addExtension, pack, UnpackrStream } from "msgpackr";

// Neovim encodes Buffer/Window/Tabpage handles as MessagePack extension
// types 0/1/2. msgpackr's default extension-0 decoder returns undefined
// (for notepack compatibility), so install Neovim handle decoders globally.
for (const type of [0, 1, 2]) {
	addExtension({
		type,
		unpack(data: Buffer) {
			return decodeHandle(data);
		},
		pack() {
			return null;
		},
	} as any);
}

// One-shot MessagePack-RPC request against a socket (e.g. Neovim's --listen
// address). Sends [0=request, msgid, method, args], resolves the response's
// raw result (or rejects its error) from [1=response, msgid, error, result].
export function msgpackRpcCall(
	server: string,
	method: string,
	args: any[] = [],
	timeoutMs = 10000,
): Promise<unknown> {
	return new Promise((resolve, reject) => {
		const unpackStream = new UnpackrStream();
		const msgid = Date.now() % 1000000;
		const client = net.createConnection(server, () => {
			client.write(pack([0, msgid, method, args]));
		});

		const timer = setTimeout(() => {
			client.destroy();
			reject(new Error(`RPC ${method} on ${server} timed out after ${timeoutMs}ms`));
		}, timeoutMs);

		client.on("error", (error) => {
			clearTimeout(timer);
			reject(error);
		});

		pipeline(client, unpackStream, () => {});

		unpackStream.on("data", (msg: any) => {
			if (!Array.isArray(msg)) return;
			if (msg[0] !== 1 || msg[1] !== msgid) return;

			clearTimeout(timer);
			client.end();

			const error = msg[2];
			error != null ? reject(toError(error)) : resolve(normalizeMsgpack(msg[3]));
		});
	});
}

function decodeHandle(data: Buffer): number {
	let value = 0;
	for (const byte of data) value = value * 256 + byte;
	return value;
}

function normalizeMsgpack(value: unknown): unknown {
	if (value instanceof Map) {
		return Object.fromEntries(Array.from(value.entries(), ([key, inner]) => [String(key), normalizeMsgpack(inner)]));
	}
	if (Array.isArray(value)) return value.map(normalizeMsgpack);
	return value;
}

function toError(value: unknown): Error {
	if (value instanceof Error) return value;
	if (typeof value === "string") return new Error(value);
	try {
		return new Error(JSON.stringify(normalizeMsgpack(value)));
	} catch {
		return new Error(String(value));
	}
}
