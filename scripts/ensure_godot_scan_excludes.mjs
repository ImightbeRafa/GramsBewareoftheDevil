import { writeFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";

/** Godot ignores .gitignore; empty .gdignore excludes a folder from the editor scan. */
const EXCLUDE_DIRS = ["node_modules", "_tmp_pixel_platformer"];

for (const dir of EXCLUDE_DIRS) {
	const marker = `${dir}/.gdignore`;
	mkdirSync(dirname(marker), { recursive: true });
	writeFileSync(marker, "");
	console.log(`Ensured ${marker}`);
}
