#!/usr/bin/env bash
set -euo pipefail

PKG='@alipay/agent-payment'
VER='1.0.0'
EXPECTED_DIST_INTEGRITY='sha512-/Ss+hS75CLYcwC8/jOj2kXzqIoJb7oKGrsiwnqly0EWVTxzD7QY5HxmFuj4anQfHVjnoh77qc2vUYiEAj0zfCA=='
REQUIRED_MAINTAINER='pub_alipay_npm <pub_alipay_npm@antgroup-inc.com>' # 支付宝官方维护账号
WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/verify-agent-payment.XXXXXX")"

cleanup() {
  rm -rf "$WORKDIR"
}

trap cleanup EXIT

# Check the pinned package metadata before installing anything locally.
meta_json="$(npm view "$PKG@$VER" name version dist.integrity dist.tarball bin maintainers --json)"

EXPECTED_DIST_INTEGRITY="$EXPECTED_DIST_INTEGRITY" REQUIRED_MAINTAINER="$REQUIRED_MAINTAINER" node -e '
const meta = JSON.parse(process.argv[1]);
const expectedDistIntegrity = process.env.EXPECTED_DIST_INTEGRITY;

function fail(message) {
  throw new Error(message);
}

if (meta.name !== "@alipay/agent-payment") {
  fail(`Unexpected package name: ${meta.name}`);
}

if (meta.version !== "1.0.0") {
  fail(`Unexpected package version: ${meta.version}`);
}

if (typeof meta["dist.integrity"] !== "string" || meta["dist.integrity"].length === 0) {
  fail("Missing dist.integrity");
}

if (meta["dist.integrity"] !== expectedDistIntegrity) {
  fail(`Unexpected dist.integrity: ${meta["dist.integrity"]}`);
}

if (typeof meta["dist.tarball"] !== "string" || meta["dist.tarball"].length === 0) {
  fail("Missing dist.tarball");
}

if (!meta.bin || typeof meta.bin !== "object" || !Object.prototype.hasOwnProperty.call(meta.bin, "agent-payment")) {
  fail("Missing agent-payment bin");
}

if (!Array.isArray(meta.maintainers) || meta.maintainers.length === 0) {
  fail("Missing maintainers");
}

if (!meta.maintainers.includes(process.env.REQUIRED_MAINTAINER)) {
  fail(`Missing required maintainer: ${process.env.REQUIRED_MAINTAINER}`);
}
' "$meta_json"

npm owner ls "$PKG"

pushd "$WORKDIR" >/dev/null
npm init -y >/dev/null
npm install --ignore-scripts "$PKG@$VER"
npm audit signatures
"./node_modules/.bin/agent-payment" install-cli
popd >/dev/null