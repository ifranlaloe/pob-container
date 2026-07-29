#define _GNU_SOURCE

#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

/*
 * Alpine's musl implementation uses faccessat2 when flags are supplied.
 * Docker Desktop's Rosetta x86_64 emulator does not expose that syscall,
 * although the older access syscall is available.  Desktop applications run
 * as an unprivileged user here, so access() has the required semantics for
 * the AT_EACCESS check made by GLib while it scans application launchers.
 */
int
faccessat (int dirfd, const char *pathname, int mode, int flags)
{
  typedef int (*faccessat_fn) (int, const char *, int, int);
  static faccessat_fn real_faccessat;

  if (mode == F_OK && (flags & AT_SYMLINK_NOFOLLOW) != 0)
    {
      struct stat statbuf;

      return fstatat (dirfd, pathname, &statbuf, AT_SYMLINK_NOFOLLOW);
    }

  if (flags != 0 && dirfd == AT_FDCWD && (flags & AT_SYMLINK_NOFOLLOW) == 0)
    return access (pathname, mode);

  if (real_faccessat == NULL)
    real_faccessat = (faccessat_fn) dlsym (RTLD_NEXT, "faccessat");

  if (real_faccessat == NULL)
    {
      errno = ENOSYS;
      return -1;
    }

  return real_faccessat (dirfd, pathname, mode, flags);
}
