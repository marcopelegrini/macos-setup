# Lessons

- Failure mode: installing launch agents as copies when symlinks are required.
  Detection signal: the user clarified that installed plists must link to repository sources.
  Prevention rule: use symbolic links for launch agents and preserve targets when replacing existing links.

- Failure mode: reading an installed plist's label without checking whether it is a dangling symlink.
  Detection signal: `plutil` reports a missing file although the directory entry exists.
  Prevention rule: distinguish symlinks from regular files and replace the link, not its target.

- Failure mode: classifying an unusual plist declaration as invalid by visual inspection.
  Detection signal: macOS `plutil -lint` accepts the file.
  Prevention rule: use the platform's plist validator before reporting syntax failures.

- Failure mode: placing service-specific configured paths in a shared path holder.
  Detection signal: the requested ownership is per service, with only resolution logic shared.
  Prevention rule: keep configured values in their consuming services and share a stateless path utility.

- Failure mode: rewriting an existing README when a small usage addition was requested.
  Detection signal: the user rejected the scope of the documentation changes.
  Prevention rule: preserve the existing page and add only the focused usage section unless a rewrite is requested.
