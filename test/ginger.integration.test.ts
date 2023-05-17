import {expect, test} from '@jest/globals';

test('makes http request', () => {

    fetch('https://wuckertdaughertyharveystammmacgyver.newapp.io').then(r => {
        expect(r.text()).resolves.toContain('Hello World')
    })

})