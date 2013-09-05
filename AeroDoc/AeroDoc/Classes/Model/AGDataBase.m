/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGDataBase.h"
#import <sqlite3.h>

@implementation AGDataBase

AGDataBase *_database;

+ (AGDataBase*)database {
    if (_database == nil) {
        _database = [[AGDataBase alloc] init];
    }
    return _database;
}

- (id)init {
    
    if ((self = [super init])) {
        // TODO cpy database from AeroDoc/Resources to
        // /Users/corinne/Library/Application Support/iPhone Simulator/6.0/Applications/8DCA886B-6FDD-4017-A883-508BDBD7C7A5/Documents
        // to have a populated DB
        // TODO Bootstrap to write in DB
        
        // The database is stored in the application bundle.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *sqLiteDb = [documentsDirectory stringByAppendingPathComponent:@"aerodoc.sqlite3"];
        
        if (sqlite3_open([sqLiteDb UTF8String], (&_database)) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
}


- (NSArray *)retrieveLeads {
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT oid, name, location, phoneNumber, saleAgent FROM lead";
    sqlite3_stmt *statement;
    int retCode = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if (retCode == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int uniqueId = sqlite3_column_int(statement, 0);
            char *nameChars = (char *) sqlite3_column_text(statement, 1);
            char *locationChars = (char *) sqlite3_column_text(statement, 2);
            char *phoneNumberChars = (char *) sqlite3_column_text(statement, 3);
            char *saleAgentChars = (char *) sqlite3_column_text(statement, 4);            
            
            NSString *name = [[NSString alloc] initWithUTF8String:nameChars];
            NSString *location = [[NSString alloc] initWithUTF8String:locationChars];
            NSString *phoneNumber = [[NSString alloc] initWithUTF8String:phoneNumberChars];
            NSString *saleAgent = [[NSString alloc] initWithUTF8String:saleAgentChars];
            
            NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
            [info setObject:[NSNumber numberWithInteger:uniqueId] forKey:@"id"];
            [info setObject:name forKey:@"name"];
            [info setObject:location forKey:@"location"];
            [info setObject:phoneNumber forKey:@"phoneNumber"];
            [info setObject:saleAgent forKey:@"saleAgent"];
            
            [retval addObject:info];

        }
        sqlite3_finalize(statement);
    }
    return retval;
    
}


@end
