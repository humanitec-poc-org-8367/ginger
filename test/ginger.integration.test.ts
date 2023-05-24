import {expect, test} from '@jest/globals';

test('makes http request', async () => {
    console.log(`APP_URL is ${process.env.APP_URL}`)
    const r = await fetch(`https://${process.env.APP_URL}`)
    const t = await r.text()
    expect(t).toContain('Hello World')

}, 30000) // jest intermittently times out waiting for all promises to resolve. Can take over 10s.