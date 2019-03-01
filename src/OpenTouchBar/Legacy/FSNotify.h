//
//  FSNotify.h
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 01/02/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

#ifndef FSNotify_h
#define FSNotify_h

void *FSNotifyStart(const char *cpath, void (*callback)(const char *, void *), void *data);
void FSNotifyStop(void *stream);

#endif /* FSNotify_h */
