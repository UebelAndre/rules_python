""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# Avoid a load from @bazel_skylib repository as users don't necessarily have it installed
load("//third_party/github.com/bazelbuild/bazel-skylib/lib:versions.bzl", "versions")

_RULE_DEPS = [
    (
        "pypi__click",
        "https://files.pythonhosted.org/packages/76/0a/b6c5f311e32aeb3b406e03c079ade51e905ea630fc19d1262a46249c1c86/click-8.0.1-py3-none-any.whl",
        "fba402a4a47334742d782209a7c79bc448911afe1149d07bdabdf480b3e2f4b6",
    ),
    (
        "pypi__colorama",
        "https://files.pythonhosted.org/packages/44/98/5b86278fbbf250d239ae0ecb724f8572af1c91f4a11edf4d36a206189440/colorama-0.4.4-py2.py3-none-any.whl",
        "9f47eda37229f68eee03b24b9748937c7dc3868f906e8ba69fbcbdd3bc5dc3e2",
    ),
    (
        "pypi__pep517",
        "https://files.pythonhosted.org/packages/f4/67/846c08e18fefb265a66e6fd5a34269d649b779718d9bf59622085dabd370/pep517-0.12.0-py2.py3-none-any.whl",
        "dd884c326898e2c6e11f9e0b64940606a93eb10ea022a2e067959f3a110cf161",
    ),
    (
        "pypi__pip",
        "https://files.pythonhosted.org/packages/47/ca/f0d790b6e18b3a6f3bd5e80c2ee4edbb5807286c21cdd0862ca933f751dd/pip-21.1.3-py3-none-any.whl",
        "78cb760711fedc073246543801c84dc5377affead832e103ad0211f99303a204",
    ),
    (
        "pypi__pip_tools",
        "https://files.pythonhosted.org/packages/dd/8d/6f9a89b65da2d4f62061ecad5e340d4fc10f63d4545ec53cd0446a296771/pip_tools-6.5.1-py3-none-any.whl",
        "80f1cfc7156e4a4465b1a46a6bb3599587909537db1a149cf3a6b73eed979ee4",
    ),
    (
        "pypi__pkginfo",
        "https://files.pythonhosted.org/packages/77/83/1ef010f7c4563e218854809c0dff9548de65ebec930921dedf6ee5981f27/pkginfo-1.7.1-py2.py3-none-any.whl",
        "37ecd857b47e5f55949c41ed061eb51a0bee97a87c969219d144c0e023982779",
    ),
    (
        "pypi__setuptools",
        "https://files.pythonhosted.org/packages/a2/e1/902fbc2f61ad6243cd3d57ffa195a9eb123021ec912ec5d811acf54a39f8/setuptools-57.1.0-py3-none-any.whl",
        "ddae4c1b9220daf1e32ba9d4e3714df6019c5b583755559be84ff8199f7e1fe3",
    ),
    (
        "pypi__tomli",
        "https://files.pythonhosted.org/packages/97/75/10a9ebee3fd790d20926a90a2547f0bf78f371b2f13aa822c759680ca7b9/tomli-2.0.1-py3-none-any.whl",
        "939de3e7a6161af0c887ef91b7d41a53e7c5a1ca976325f429cb46ea9bc30ecc",
    ),
    (
        "pypi__wheel",
        "https://files.pythonhosted.org/packages/65/63/39d04c74222770ed1589c0eaba06c05891801219272420b40311cd60c880/wheel-0.36.2-py2.py3-none-any.whl",
        "78b5b185f0e5763c26ca1e324373aadd49182ca90e825f7853f4b2509215dc0e",
    ),
]

_GENERIC_WHEEL = """\
package(default_visibility = ["//visibility:public"])

load("@rules_python//python:defs.bzl", "py_library")

py_library(
    name = "lib",
    srcs = glob(["**/*.py"]),
    data = glob(["**/*"], exclude=["**/*.py", "**/* *", "BUILD", "WORKSPACE"]),
    # This makes this directory a top-level in the python import
    # search path for anything that depends on this.
    imports = ["."],
)
"""

# Collate all the repository names so they can be easily consumed
all_requirements = [name for (name, _, _) in _RULE_DEPS]

def requirement(pkg):
    return "@pypi__" + pkg + "//:lib"

def pip_install_dependencies():
    """
    Fetch dependencies these rules depend on. Workspaces that use the pip_install rule can call this.

    (However we call it from pip_install, making it optional for users to do so.)
    """

    # We only support Bazel LTS and rolling releases.
    # Give the user an obvious error to upgrade rather than some obscure missing symbol later.
    # It's not guaranteed that users call this function, but it's used by all the pip fetch
    # repository rules so it's likely that most users get the right error.
    versions.check("4.0.0")

    for (name, url, sha256) in _RULE_DEPS:
        maybe(
            http_archive,
            name,
            url = url,
            sha256 = sha256,
            type = "zip",
            build_file_content = _GENERIC_WHEEL,
        )
