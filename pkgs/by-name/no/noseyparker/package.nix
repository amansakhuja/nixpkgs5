{
  lib,
  rustPlatform,
  fetchFromGitHub,
  buildPackages,
  boost,
  cmake,
  git,
  vectorscan,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "noseyparker";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "praetorian-inc";
    repo = "noseyparker";
    tag = "v${version}";
    hash = "sha256-6GxkIxLEgbIgg4nSHvmRedm8PAPBwVxLQUnQzh3NonA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-hVBHIm/12WU6g45QMxxuGk41B0kwThk7A84fOxArvno=";

  nativeCheckInputs = [
    git
  ];

  checkFlags = [
    # These tests expect access to network to clone and use GitHub API
    "--skip=github::github_repos_list_multiple_user_dedupe_jsonl_format"
    "--skip=github::github_repos_list_org_badtoken"
    "--skip=github::github_repos_list_user_badtoken"
    "--skip=github::github_repos_list_user_human_format"
    "--skip=github::github_repos_list_user_json_format"
    "--skip=github::github_repos_list_user_jsonl_format"
    "--skip=github::github_repos_list_user_repo_filter"
    "--skip=scan::appmaker::scan_workflow_from_git_url"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  depsBuildBuild = [
    # Fix error: failed to run custom build command for `vectorscan-rs-sys v0.0.5`
    # Failed to get C++ compiler version: Os { code: 2, kind: NotFound, message: "No such file or directory" }
    buildPackages.stdenv.cc
  ];

  buildInputs = [
    boost
    vectorscan
    openssl
  ];

  env.OPENSSL_NO_VENDOR = 1;

  meta = {
    description = "Find secrets and sensitive information in textual data";
    mainProgram = "noseyparker";
    homepage = "https://github.com/praetorian-inc/noseyparker";
    changelog = "https://github.com/praetorian-inc/noseyparker/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ _0x4A6F ];
  };
}
