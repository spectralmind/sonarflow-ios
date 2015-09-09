#pragma once

#define STAssertDifferentObjects(first, second, message) \
STAssertFalse([first isEqual:second], message);
