//
//  JDHotFixConfig.m
//  JDHotFix
//
//  Created by JiangDong Zhang on 2022/3/28.
//

#import "JDHotFixConfig.h"
#import "JDHotfix.h"
#import <SSZipArchive/SSZipArchive.h>


@interface JDHotFixConfig ()

@end


@implementation JDHotFixConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)configHotFix {
    
#ifdef DEBUG

    NSString *patchFilePath = [[NSBundle mainBundle] pathForResource:@"hotfix" ofType:@"js"];
    [[JDHotfix shared] fixAtPath:patchFilePath];
#else

    [self checkHotFixPatch];
#endif

    
}


static NSString *const patchPath = @"com.jdtext/mppatch";

NS_INLINE NSString *PatchFileDirectory() {
    return [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:patchPath];
}

NS_INLINE NSString *VersionPatchFileDirtory() {
    return [PatchFileDirectory() stringByAppendingPathComponent:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]];
}

NS_INLINE NSString *PatchFilePath(NSString * fileName) {
    return [VersionPatchFileDirtory() stringByAppendingPathComponent:fileName];
}

NS_INLINE NSString *ZipToJSName(NSString *fileName) {
    if ([fileName containsString:@".js.zip"]) {
        fileName = [fileName stringByReplacingOccurrencesOfString:@".zip" withString:@""];
    }else if ([fileName containsString:@".zip"]) {
        fileName = [fileName stringByReplacingOccurrencesOfString:@".zip" withString:@".js"];
    }
    if ([fileName hasSuffix:@".js"]) {
        return fileName;
    }
    return @"";
}

- (NSString *)appVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

- (void)checkHotFixPatch
{
//    NSDictionary *hotFixInfo = [[MPAppDefaults standardUserDefaults] hotFixConfig];
    NSString *zipURL =  @"";//[hotFixInfo mp_safeStringForKey:@"hf_zip_url"];
//    BOOL enable = [hotFixInfo mp_safeBoolForKey:@"hf_enable"];
//    if (!enable || zipURL.length == 0) {
//        return;
//    }
    NSString *fileName = [zipURL lastPathComponent];
    NSArray  <NSString *> *arr = [fileName componentsSeparatedByString:@"_"];
    if (arr.count != 2 || ![arr[0] isEqualToString:[self appVersion]]) {
        return;
    }
    NSString *patchDirectory = VersionPatchFileDirtory();
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if (![fm fileExistsAtPath:patchDirectory isDirectory:&isDirectory]) {
        [self downloadPatchWithURL:zipURL];
    }else {
        fileName = ZipToJSName(fileName);
        NSArray <NSString *> *files = [fm contentsOfDirectoryAtPath:patchDirectory error:nil];
        __block BOOL needUpdate = YES;
        [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:fileName] && [obj hasSuffix:@".js"]) {
                needUpdate = NO;
                *stop = YES;
            }
        }];
        if (needUpdate) {
            [self downloadPatchWithURL:zipURL];
        }else {
            ///加载本地脚本
            [self readLocalHotFixPatch:fileName];
        }
    }
}

- (void)readLocalHotFixPatch:(NSString *)fileName
{
    if (fileName.length > 0) {
        fileName = PatchFilePath(fileName);
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
            [[JDHotfix shared] fixAtPath:fileName];
        }
    }
}

- (void)downloadPatchWithURL:(NSString *)zipURL {
    NSURL *URL = [NSURL URLWithString:zipURL];
    NSArray *array = [URL pathComponents];

    NSString *tempPath = NSTemporaryDirectory();
    NSString *fileName = [array lastObject];
    NSString *tempZipPath = [tempPath stringByAppendingPathComponent:fileName];
    NSString *patchDirectory = VersionPatchFileDirtory();
    BOOL isDirectory = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:patchDirectory isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:patchDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    /* 下载hotfix js文件
    [MPHttp downloadWithUrl:zipURL downloadProgress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:tempZipPath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {
            dispatch_async(self.fileHanderQueue, ^{
                //下载成功移动到缓存目录
                NSError *moveError = nil;
                [[NSFileManager defaultManager] moveItemAtPath:tempZipPath toPath:[patchDirectory stringByAppendingPathComponent:fileName] error:&moveError];
                ///移除临时文件
                if (!moveError) {
                    [[NSFileManager defaultManager] removeItemAtPath:tempZipPath error:nil];
                }
                ///解压
                [self unzipPatchWithFileNamae:fileName];
            });
        }
    }];
     */
    

}

- (void)unzipPatchWithFileNamae:(NSString *)fileName
{
    NSString *zipFile = PatchFilePath(fileName);
    [SSZipArchive unzipFileAtPath:zipFile toDestination:VersionPatchFileDirtory() progressHandler:nil completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        if (succeeded && !error) {
            [self removeCurrentVersionZipWithFileName:fileName];
            NSString *fn = ZipToJSName(fileName);
            [self readLocalHotFixPatch:fn];
        }
    }];
}

- (void)removeCurrentVersionZipWithFileName:(NSString *)fileName
{
    NSString *zipFile = PatchFilePath(fileName);
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:zipFile error:nil];
    ///删除之前的 js文件
    NSArray <NSString *> *files = [fm contentsOfDirectoryAtPath:VersionPatchFileDirtory() error:nil];
    NSString *fn = ZipToJSName(fileName);
    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isEqualToString:fn]) {
            NSString *del = PatchFilePath(obj);
            [fm removeItemAtPath:del error:nil];
        }
    }];
}

///删除往期版本的补丁
- (void)removeUnusedPathFile
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:PatchFileDirectory() error:nil];
    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isEqualToString:[self appVersion]]) {
            [fm removeItemAtPath:[PatchFileDirectory() stringByAppendingPathComponent:obj] error:nil];
        }
    }];
}

@end
