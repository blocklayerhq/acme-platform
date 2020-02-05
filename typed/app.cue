package main

// import (
//  "infralabs.io/acme/bl"
//  "infralabs.io/acme/templates"
// )

// // A single instance of an Acme Clothing application
// App :: {
//  monorepo: bl.Directory | *bl.EmptyDirectory
//  hostname: string
//  api: {
//   container: {}
//   registry: {}
//   kub: {}
//   db: {}
//  }
//  frontend: {
//   app: templates.Yarn & {
//    source:       monorepo & {path: "crate/code/web"}
//    writeEnvFile: ".env"
//    loadEnv:      false
//    environment: {
//     NODE_ENV: "production"
//     APP_URL:  "https://\(hostname)"
//    }
//    buildDirectory: "public"
//    buildScript:    "build:client"
//   }

//   deploy: templates.Netlify & {
//    artifact:   app.build
//    createSite: true
//    domain:     hostname
//   }
//  }
// }
