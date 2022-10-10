/*
  Hook __xstat() to evade hardcoded paths in applications

  References:

  * Replacing hard coded paths in ELF binaries - tape software
    https://tapesoftware.net/replace-symbol/
  * fnmatch(3) manpage
    man:/fnmatch(3)

  Copyright 2022 林博仁(Buo-ren, Lin) <Buo.Ren.Lin@gmail.com>
  SPDX-License-Identifier: MIT
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fnmatch.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

static const char hardcoded_path_glob[] = "/usr/share/iscan/*.bin";
static const char hardcoded_path_prefix[] = "/usr/share/iscan/";

int __xstat_wrapper(int ver, const char *path, struct stat *stat_buf){
    fprintf(stderr, "DEBUG: __xstat_wrapper: __xstat() function hook called.\n");

    int match_result = FNM_NOMATCH;

    /* TODO: Add FNM_EXTMATCH for case insensitive filename matching */
    match_result = fnmatch(hardcoded_path_glob, path, FNM_PATHNAME|FNM_NOESCAPE);

    int stat_result = 0;
    switch(match_result){
        case 0:
            fprintf(stderr, "DEBUG: __xstat_wrapper: Hardcoded path detected.\n");
            const int hardcoded_path_prefix_length = strlen(hardcoded_path_prefix);
            const char *remaining_path = path + hardcoded_path_prefix_length * sizeof(char);
            fprintf(stderr, "DEBUG: __xstat_wrapper: Remaining path determined to be = \"%s\".\n", remaining_path);
            size_t remaining_path_length = strlen(remaining_path);

            char * snap_user_common_dir = NULL;
            snap_user_common_dir = getenv("SNAP_USER_COMMON");
            unsigned int snap_user_common_dir_length = 0;
            snap_user_common_dir_length = strlen(snap_user_common_dir);

            const char * appended_firmware_dir_path = "/firmware/";
            unsigned int appended_firmware_dir_path_length = 0;
            appended_firmware_dir_path_length = strlen(appended_firmware_dir_path);

            char * patched_path = NULL;
            patched_path = (char *) malloc(snap_user_common_dir_length + appended_firmware_dir_path_length + remaining_path_length + 1);
            strcpy(patched_path, snap_user_common_dir);
            strcat(patched_path, appended_firmware_dir_path);
            strcat(patched_path, remaining_path);

            printf("DEBUG: __xstat_wrapper: Hardcoded path patched to \"%s\".\n", patched_path);
            stat_result = __xstat(ver, patched_path, stat_buf);
            free(patched_path);
            break;

        case FNM_NOMATCH:
            stat_result = __xstat(ver, path, stat_buf);
            break;

        default:
            fprintf(stderr, "Error: __xstat_wrapper: Unknown fnmatch error.\n");
            exit(EXIT_FAILURE);
            break;
    }
    return stat_result;
}
