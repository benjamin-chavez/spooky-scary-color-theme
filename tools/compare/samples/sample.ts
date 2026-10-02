// Types and interfaces
import type { Readable } from "node:stream";

interface Costume {
  readonly name: string;
  size: "S" | "M" | "L";
  price?: number;
}

type Treat = { kind: "candy"; sugar: number } | { kind: "apple" };

enum Phase {
  Dusk = 1,
  Midnight,
  Dawn,
}

export abstract class Haunt<T extends Costume> implements Iterable<T> {
  protected items: T[] = [];
  private static count = 0;

  constructor(public readonly location: string) {
    Haunt.count++;
  }

  abstract summon(): Promise<void>;

  *[Symbol.iterator](): Iterator<T> {
    yield* this.items;
  }

  add(item: T): this {
    this.items.push(item);
    return this;
  }
}

function tally(treats: Treat[], bonus = 0): number {
  let sugar = bonus;
  for (const treat of treats) {
    if (treat.kind === "candy") {
      sugar += treat.sugar;
    }
  }
  return sugar;
}

const phase: Phase = Phase.Midnight;
const total = tally([{ kind: "candy", sugar: 12 }, { kind: "apple" }], 2);
export { tally, phase, total };
