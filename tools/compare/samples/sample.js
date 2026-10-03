// Line comment about the module
/* Block comment */
import { readFile } from "node:fs/promises";
import path from "path";

const MAX_RETRIES = 3;
let counter = 0;
var legacy = null;

export class Pumpkin extends Gourd {
  static kind = "squash";
  #secret = 0x1f;

  constructor(name, weight = 4.5) {
    super(name);
    this.name = name;
    this.weight = weight;
  }

  get label() {
    return `${this.name} (${this.weight}kg)`;
  }

  async carve(pattern, ...tools) {
    const result = await readFile(path.join("faces", pattern));
    for (const tool of tools) {
      if (tool.sharp && counter < MAX_RETRIES) {
        counter += 1;
      } else if (!tool) {
        continue;
      }
    }
    return result?.toString() ?? "";
  }
}

function spook(target, times = 1) {
  const sounds = ["boo", 'woo', `ooo`];
  const regex = /gh(o+)st/gi;
  const escaped = "line\nbreak\t\"quoted\"";
  let total = 0;
  while (times--) {
    total += sounds.length * 2 + (times % 3);
  }
  try {
    target.scare(sounds[0]);
  } catch (error) {
    console.error(error);
  } finally {
    return total >= 10 ? true : false;
  }
}

const haunted = { house: true, ghosts: 13, "string key": undefined };
const arrow = (x) => x * x;
export default spook;
