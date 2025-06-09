# Ball

The crappiest remake.

## Rough Break Down

- 8 x 10 grid area, where blocks and more balls spawn in the top row.
- Player aims using small preview and lets their collection of balls try to eliminate blocks by reaching number of times they are supposed to be hit.
- Small acceleration downwards to prevent balls from getting stuck in a horizontal loop.

So need to know how to deal with collisions. It is just reflections when dealing with elastic collisions, so the pain point becomes noticing there should be a collision (ball overlaps with wall or is inside block, which hopefully doesn't get drawn).

Curious whether it'd be quicker to deal with timestepping or analytical paths (uniform gravitational field path is easy to find, just need to find intercept with blocks). Probably timestepping will give more consistent speed; use something like RK4. Curious to know how good Lua is at caching, because with a lot of balls the same path over and over should hit caches well.

Lua Love engine should give some nice game visuals by the end. I like them filters Balatro.

## Some Steps

1. Deal with the motion of one ball, bouncing on the screen. Screen is a good check of a block.
2. Add one block and check collisions look right. Check multiple balls.
With collisions working fine can start actually making game mechanics occur.
3. Fire ball in direction of user input.
4. Spawn blocks in with count.
5. Spawn extra balls.
6. Profit

## Classes

Ball - One ball. Velocity, position.
Block - Grid Position, Count.
Bonus - Bonus ball for now, but could provide more little bonus items spawning.
