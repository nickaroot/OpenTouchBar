//
//  OpenTouchBar-Bridging-Header.h
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 30/12/2018.
//  Copyright © 2018 Nikita Arutyunov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#import "CBBlueLightClient.h"
#import "FSNotify.h"

#import <objc/runtime.h>

/**
 *  Gets a list of all methods on a class (or metaclass)
 *  and dumps some properties of each
 *
 *  @param clz the class or metaclass to investigate
 */
void DumpObjcMethods(Class clz) {
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    
    printf("Found %d methods on '%s'\n", methodCount, class_getName(clz));
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        
        printf("\t'%s' has method named '%s' of encoding '%s'\n",
               class_getName(clz),
               sel_getName(method_getName(method)),
               method_getTypeEncoding(method));
        
        /**
         *  Or do whatever you need here...
         */
    }
    
    free(methods);
}
