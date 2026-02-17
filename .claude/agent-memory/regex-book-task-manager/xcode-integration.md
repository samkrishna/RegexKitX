# Xcode Project Integration Notes

## Adding a New Test File

Three sections of project.pbxproj must be updated:

### 1. PBXFileReference section
```
AA000000XX000000AABB0001 /* MasteringRegexChXXTests.m */ = {
    isa = PBXFileReference;
    explicitFileType = sourcecode.c.objc.preprocessed;
    path = MasteringRegexChXXTests.m;
    sourceTree = "<group>";
};
```

### 2. PBXBuildFile section
```
AA000000XX000000AABB0002 /* MasteringRegexChXXTests.m in Sources */ = {
    isa = PBXBuildFile;
    fileRef = AA000000XX000000AABB0001 /* MasteringRegexChXXTests.m */;
};
```

### 3. PBXGroup children (RegexKitXTests group, ID 6F2B4E141EF5B85000DB6629)
Add fileRef ID to children array.

### 4. PBXSourcesBuildPhase (test target Sources, ID 6F2B4E0C1EF5B85000DB6629)
Add buildFile ID to files array.

## ID Scheme Used
- Ch01: AA00000001000000AABB0001 / AA00000001000000AABB0002
- Ch02: AA00000002000000AABB0001 / AA00000002000000AABB0002
- Ch03: AA00000003000000AABB0001 / AA00000003000000AABB0002
- Ch05: AA00000005000000AABB0001 / AA00000005000000AABB0002
- Ch04: AA00000004000000AABB0001 / AA00000004000000AABB0002 (next)
- Ch06: AA00000006000000AABB0001 / AA00000006000000AABB0002 (next)

## Verification
After modifying pbxproj, always run: `xcodebuild test -scheme RegexKitX`
