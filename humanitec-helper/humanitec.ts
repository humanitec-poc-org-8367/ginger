import {Command} from 'commander';

const environments = async (apiToken: string) => {

    console.log(`Humanitec listing environments for app ginger`)
    const r = await fetch("https://api.humanitec.io/orgs/htc-demo-04/apps/ginger/envs", {
        headers: {
            "Authorization": `Bearer ${apiToken}`
        }
    })

    const j = await r.json()

    console.log(JSON.stringify(j, null, 4))
}

const program = new Command("humanitec")
program.command("environments")
    .description("List all Humanitec environments for a given app")
    .argument("<apiToken>", "The Humanitec API token")
    .action((apiToken) => {
        environments(apiToken)
    })

program.parse(process.argv)