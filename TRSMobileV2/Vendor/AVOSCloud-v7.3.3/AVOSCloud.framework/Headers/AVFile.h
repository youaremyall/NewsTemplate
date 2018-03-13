//
//  AVFile.h
//  LeanCloud
//

#import <Foundation/Foundation.h>
#import "AVConstants.h"
#import "AVACL.h"

@class AVFileQuery;

NS_ASSUME_NONNULL_BEGIN

/*!
 A file of binary data stored on the LeanCloud servers. This can be a image, video, or anything else
 that an application needs to reference in a non-relational way.
 */
@interface AVFile : NSObject <NSCoding>

/** @name Creating a AVFile */

/*!
 Creates a file with given data. A name will be assigned to it by the server.
 @param data The contents of the new AVFile.
 @return A AVFile.
 */
+ (instancetype)fileWithData:(NSData *)data;

/*!
 Creates a file with given data and name.
 @param name The name of the new AVFile.
 @param data The contents of the new AVFile.
 @return A AVFile.
 */
+ (instancetype)fileWithName:(nullable NSString *)name data:(NSData *)data;


/*!
 Creates a file with given url.
 @warning only for getting image thumbnail with a known QiNiu file url
 @param url The url of file.
 @return an AVFile.
 */
+ (instancetype)fileWithURL:(NSString *)url;

/*!
 Creates a file with the contents of another file.
 @param name The name of the new AVFile
 @param path The path to the file that will be uploaded to LeanCloud
 */
+ (instancetype)fileWithName:(nullable NSString *)name
              contentsAtPath:(NSString *)path;

/*!
 Creates a file with an AVObject. 
 @param object an AVObject.
 @return an AVFile.
 */
+ (instancetype)fileWithAVObject:(AVObject *)object;

/*!
The name of the file.
 */
@property (nonatomic, readonly, copy, nullable) NSString *name;

/*!
 The id of the file.
 */
@property (nonatomic, copy, nullable) NSString * objectId;


/*!
 The url of the file.
 */
@property (nonatomic, readonly, copy, nullable) NSString *url;

/*!
 The Qiniu bucket of the file.
 */
@property (nonatomic, readonly, copy, nullable) NSString *bucket;

/** @name Storing Data with LeanCloud */

/*!
 Whether the file has been uploaded for the first time.
 */
@property (nonatomic, readonly, assign) BOOL isDirty;

/*!
 File metadata, caller is able to store additional values here.
 */
@property (nonatomic, strong, nullable) NSMutableDictionary * metadata AV_DEPRECATED("2.6.1以后请使用metaData");
/*!
 File metadata, caller is able to store additional values here.
 */
@property (nonatomic, strong, nullable) NSMutableDictionary * metaData;

/*!
 *  The access control list  for this file.
 */
@property (nonatomic, strong, nullable) AVACL *ACL;

/*!
 Request headers for file uploading.

 Some file hosting services allow you set custom headers in uploading request.
 Currently, it only supports files in US node, aka. the files hosted on AmazonS3.
 See http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPUT.html for all request headers.
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *uploadingHeaders;

/*!
 Saves the file.
 @return whether the save succeeded.
 */
- (BOOL)save;

/*!
 Saves the file and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @return whether the save succeeded.
 */
- (BOOL)save:(NSError **)error;

/*!
 An alias of `-[AVFile save:]` methods that supports Swift exception.
 @seealso `-[AVFile save:]`
 */
- (BOOL)saveAndThrowsWithError:(NSError **)error;

/*!
 Saves the file asynchronously.
 */
- (void)saveInBackground;

/*!
 Saves the file asynchronously and executes the given block.
 @param block The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)saveInBackgroundWithBlock:(AVBooleanResultBlock)block;

/*!
 Saves the file asynchronously and executes the given resultBlock. Executes the progressBlock periodically with the percent
 progress. progressBlock will get called with 100 before resultBlock is called.
 @param block The block should have the following argument signature: (BOOL succeeded, NSError *error)
 @param progressBlock The block should have the following argument signature: (int percentDone)
 */
- (void)saveInBackgroundWithBlock:(AVBooleanResultBlock)block
                    progressBlock:(nullable AVProgressBlock)progressBlock;

/*!
 Saves the file asynchronously and calls the given callback.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
- (void)saveInBackgroundWithTarget:(id)target selector:(SEL)selector;

/** @name Getting Data from LeanCloud */

/*!
 Whether the data is available in memory or needs to be downloaded.
 */
@property (readonly) BOOL isDataAvailable;

/*!
 Gets the data from cache if available or fetches its contents from the LeanCloud
 servers.
 @return The data. Returns nil if there was an error in fetching.
 */
- (nullable NSData *)getData;

/*!
 This method is like getData but avoids ever holding the entire AVFile's
 contents in memory at once. This can help applications with many large AVFiles
 avoid memory warnings.
 @return A stream containing the data. Returns nil if there was an error in 
 fetching.
 */
- (nullable NSInputStream *)getDataStream;

/*!
 Gets the data from cache if available or fetches its contents from the LeanCloud
 servers. Sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @return The data. Returns nil if there was an error in fetching.
 */
- (nullable NSData *)getData:(NSError **)error;

/*!
 This method is like getData: but avoids ever holding the entire AVFile's
 contents in memory at once. This can help applications with many large AVFiles
 avoid memory warnings. Sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @return A stream containing the data. Returns nil if there was an error in 
 fetching.
 */
- (nullable NSInputStream *)getDataStream:(NSError **)error;

/*!
 Asynchronously gets the data from cache if available or fetches its contents 
 from the LeanCloud servers. Executes the given block.
 @param block The block should have the following argument signature: (NSData *result, NSError *error)
 */
- (void)getDataInBackgroundWithBlock:(AVDataResultBlock)block;

/*!
 This method is like getDataInBackgroundWithBlock: but avoids ever holding the 
 entire AVFile's contents in memory at once. This can help applications with
 many large AVFiles avoid memory warnings.
 @param block The block should have the following argument signature: (NSInputStream *result, NSError *error)
 */
- (void)getDataStreamInBackgroundWithBlock:(AVDataStreamResultBlock)block;

/*!
 Asynchronously gets the data from cache if available or fetches its contents 
 from the LeanCloud servers. Executes the resultBlock upon
 completion or error. Executes the progressBlock periodically with the percent progress. progressBlock will get called with 100 before resultBlock is called.
 @param resultBlock The block should have the following argument signature: (NSData *result, NSError *error)
 @param progressBlock The block should have the following argument signature: (int percentDone)
 */
- (void)getDataInBackgroundWithBlock:(AVDataResultBlock)resultBlock
                       progressBlock:(nullable AVProgressBlock)progressBlock;

/*!
 This method is like getDataInBackgroundWithBlock:progressBlock: but avoids ever
 holding the entire AVFile's contents in memory at once. This can help 
 applications with many large AVFiles avoid memory warnings.
 @param resultBlock The block should have the following argument signature: (NSInputStream *result, NSError *error)
 @param progressBlock The block should have the following argument signature: (int percentDone)
 */
- (void)getDataStreamInBackgroundWithBlock:(AVDataStreamResultBlock)resultBlock
                             progressBlock:(nullable AVProgressBlock)progressBlock;

/*!
 Asynchronously gets the data from cache if available or fetches its contents 
 from the LeanCloud servers.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSData *)result error:(NSError *)error. error will be nil on success and set if there was an error.
 */
- (void)getDataInBackgroundWithTarget:(id)target selector:(SEL)selector;

/** @name Interrupting a Transfer */

/*!
 Cancels the current request (whether upload or download of file data).
 */
- (void)cancel;


/*!
 Gets a AVFile asynchronously and calls the given block with the result.
 
 @param objectId The objectId associated with file object. 
 @param block The block to execute. The block should have the following argument signature: (AVFile *file, NSError *error)
 */
+ (void)getFileWithObjectId:(NSString *)objectId
                  withBlock:(AVFileResultBlock)block;

/*!
 Get a thumbnail URL for image saved on Qiniu.

 @param scaleToFit Scale the thumbnail and keep aspect ratio.
 @param width The thumbnail width.
 @param height The thumbnail height.
 @param quality The thumbnail image quality in 1 - 100.
 @param format The thumbnail image format such as 'jpg', 'gif', 'png', 'tif' etc.
 */
- (nullable NSString *)getThumbnailURLWithScaleToFit:(BOOL)scaleToFit
                                               width:(int)width
                                              height:(int)height
                                             quality:(int)quality
                                              format:(nullable NSString *)format;

/*!
 Get a thumbnail URL for image saved on Qiniu.
 @see -getThumbnailURLWithScaleToFit:width:height:quality:format

 @param scaleToFit Scale the thumbnail and keep aspect ratio.
 @param width The thumbnail width.
 @param height The thumbnail height.
 */
- (nullable NSString *)getThumbnailURLWithScaleToFit:(BOOL)scaleToFit
                                               width:(int)width
                                              height:(int)height;

/*!
 Gets a thumbnail asynchronously and calls the given block with the result.
 
 @param scaleToFit Scale the thumbnail and keep aspect ratio.
 @param width The desired width.
 @param height The desired height.
 @param block The block to execute. The block should have the following argument signature: (UIImage *image, NSError *error)
 */
- (void)getThumbnail:(BOOL)scaleToFit
               width:(int)width
              height:(int)height
           withBlock:(AVImageResultBlock)block;

/*!
 Create an AVFileQuery which returns files.
 */
+ (AVFileQuery *)query;

/*!
 Sets a owner id to metadata.
 
 @param ownerId The owner objectId.
 */
-(void)setOwnerId:(nullable NSString *)ownerId;

/*!
 Gets owner id from metadata.

 */
-(nullable NSString *)ownerId;


/*!
 Gets file size in bytes.
 */
-(NSUInteger)size;

/*!
 Gets file path extension from url, name or local file path.
 */
-(nullable NSString *)pathExtension;

/*!
 Gets local file path.
 */
- (nullable NSString *)localPath;

/*!
 Remove file in background.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)deleteInBackgroundWithBlock:(AVBooleanResultBlock)block;

/*!
 Delete an array of files asynchronously.

 @param files The files to be deleted.
 @param block The callback of deletion request.
 */
+ (void)deleteFiles:(NSArray<AVFile *> *)files inBackgroundWithBlock:(AVBooleanResultBlock)block;

/*!
 Remove file in background.
 */
- (void)deleteInBackground;


/** @name Cache management */

/*!
 Clear file cache.
 */
- (void)clearCachedFile;

/**
 *  clear All Cached AVFiles
 *
 *  @return clear success or not
 */
+ (BOOL)clearAllCachedFiles;

/**
 *  clear All Cached AVFiles by days ago
 *
 *  @param numberOfDays number Of Days
 *
 *  @return clear success or not
 */
+ (BOOL)clearCacheMoreThanDays:(NSInteger)numberOfDays;


@end

NS_ASSUME_NONNULL_END
