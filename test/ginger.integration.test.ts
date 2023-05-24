import {expect, test} from '@jest/globals';

test('makes http request', async () => {
    //process.env.APP_URL = 'wuckertdaughertyharveystammmacgyver.newapp.io'
    const appUrl= `https://${process.env.APP_URL}`
    console.log(`APP_URL is ${appUrl}`)
    const r = await fetch(appUrl)
    const t = await r.text()
    expect(t).toContain('Hello World')

}, 30000) // jest intermittently times out waiting for all promises to resolve. Can take over 10s.