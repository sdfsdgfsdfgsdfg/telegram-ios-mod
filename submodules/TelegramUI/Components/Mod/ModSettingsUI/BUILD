load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ModSettingsUI",
    module_name = "ModSettingsUI",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/AccountContext",
        "//submodules/Display",
        "//submodules/ItemListUI",
        "//submodules/PresentationDataUtils",
        "//submodules/SSignalKit/SwiftSignalKit",
        "//submodules/TelegramCore",
        "//submodules/TelegramPresentationData",
    ],
    visibility = [
        "//visibility:public",
    ],
)
