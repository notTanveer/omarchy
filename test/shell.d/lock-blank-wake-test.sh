#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// Armed at blank time the idle notification never primes under someone typing
// straight in, so it has to be armed for the whole lock.
assert(
  /IdleMonitor \{\s*id: blankWakeMonitor\s*enabled: root\.lockRequested\s*timeout: 1\s*respectInhibitors: false\s*onIsIdleChanged: if \(!isIdle && root\.displaysBlank\) root\.runWake\(\)/.test(serviceQml),
  'the keyboard wake monitor is armed for the whole lock and only wakes a blanked screen'
)

// Keys the field cannot hear still reach the compositor; blanking under them
// would leave the monitor with no idle edge to wake on.
assert(
  /if \(root\.lockRequested && !blankWakeMonitor\.isIdle\) \{\s*root\.armBlankTimer\(\)\s*return\s*\}/.test(serviceQml),
  'the blank waits while the compositor still sees input'
)
JS
