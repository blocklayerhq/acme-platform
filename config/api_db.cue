package main

RDSAurora :: {

    dbName: string
    arn: string
    secretArn: string

    adminAuth: {
        username: secret
        password: secret
    }

    awsConfig: {
		region: string
		accessKey: secret
		secretKey: secret
	}

    // FIXME: add support for create new user/pwd
    create_db: task & {
        input: {
        	"/aws/region": awsConfig.region
			"/aws/access_key": awsConfig.accessKey
			"/aws/secret_key": awsConfig.secretKey
            "/db/arn": arn
            "/db/secret_arn": secretArn
            "/db/name": dbName
            "/auth/username": adminAuth.username
            "/auth/password": adminAuth.password
        }

        output: {
            "/db_name": string
        }

        os: {
            package: {
                python: true
                coreutils: true
            }
            extraCommand: [
                "apk add --no-cache py-pip && pip install awscli && apk del py-pip"
            ]
        }

        code: #"""
            export AWS_DEFAULT_REGION="$(cat /aws/region)"
            export AWS_ACCESS_KEY_ID="$(cat /aws/access_key)"
            export AWS_SECRET_ACCESS_KEY="$(cat /aws/secret_key)"

            set +e

            aws rds-data execute-statement \
                --cli-connect-timeout 60 \
                --cli-read-timeout 60 \
                --resource-arn "$(cat /db/arn)" \
                --secret-arn "$(cat /db/secret_arn)" \
                --sql "CREATE DATABASE \`$(cat /db/name)\`" \
                --no-include-result-metadata \
            |& tee /tmp/out
            exit_code=${PIPESTATUS[0]}
            if [ $exit_code -ne 0 ]; then
                cat /tmp/out
                grep -q "database exists" /tmp/out
                [ $? -ne 0 ] && exit $exit_code
            fi

            cp /db/name /db_name
        """#
    }

}
