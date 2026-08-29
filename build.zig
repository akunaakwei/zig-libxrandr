const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(std.builtin.LinkMode, "linkage", "Linkage type for the library") orelse .static;

    const xrandr_dep = b.dependency("xrandr", .{});
    const x11_dep = b.dependency("x11", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });
    const x11 = x11_dep.artifact("x11");
    const xorgproto_dep = b.dependency("xorgproto", .{
        .target = target,
        .optimize = optimize,
    });
    const xorgproto = xorgproto_dep.artifact("xorgproto");
    const xrender_dep = b.dependency("xrender", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });
    const xrender = xrender_dep.artifact("xrender");
    const xext_dep = b.dependency("xext", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });
    const xext = xext_dep.artifact("xext");

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .pic = if (linkage == .dynamic) true else null,
    });
    mod.linkLibrary(x11);
    mod.linkLibrary(xorgproto);
    mod.linkLibrary(xrender);
    mod.linkLibrary(xext);
    mod.addIncludePath(xrandr_dep.path("include/X11/extensions"));
    mod.addCSourceFiles(.{
        .root = xrandr_dep.path("src"),
        .files = &sources,
    });

    const lib = b.addLibrary(.{
        .name = "xrandr",
        .root_module = mod,
        .linkage = linkage,
    });
    lib.installHeadersDirectory(xrandr_dep.path("include"), ".", .{});
    b.installArtifact(lib);
}

const sources = .{
    "Xrandr.c",
    "XrrConfig.c",
    "XrrCrtc.c",
    "XrrMode.c",
    "XrrOutput.c",
    "XrrProperty.c",
    "XrrScreen.c",
    "XrrProvider.c",
    "XrrProviderProperty.c",
    "XrrMonitor.c",
};
