import React, { useState } from "react";

type Props = { title: string; spooky?: boolean };

export function Banner({ title, spooky = false }: Props) {
  const [count, setCount] = useState<number>(0);
  const label = spooky ? "Boo!" : "Hello";

  return (
    <section className="banner" data-spooky={spooky}>
      <h1 id="title">{title}</h1>
      <p>
        {label} clicked {count} times
      </p>
      <button onClick={() => setCount(count + 1)} disabled={count > 9}>
        Scare
      </button>
      {/* JSX comment */}
    </section>
  );
}
