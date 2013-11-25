package require Tcl 8.5
package require tcltest 2
namespace import ::tcltest::test ::tcltest::makeFile ::tcltest::removeFile

# Use the test directory as the working directory for all tests.
::tcltest::workingDirectory [file dirname [info script]]

# Stow any temporary test files in a tmp subdirectory.
::tcltest::configure -tmpdir tmp

# Apply any additional configuration arguments.
eval ::tcltest::configure $argv

# Because these tests are more time consuming than others, they are skipped
# by default. To run them, run `tclsh test/static.test.tcl -constraints static`

::tcltest::testConstraint has_splint [expr {![catch {exec which splint}]}]
::tcltest::testConstraint has_cppcheck [expr {![catch {exec which cppcheck}]}]
::tcltest::testConstraint has_clang [expr {![catch {exec which clang}]}]

test static-splint-1 {
# Check that Splint reports no issues (-weak mode).
} -constraints {
	static
	has_splint
} -body {
	# +quiet suppresses "herald" line and error count (simplifies success case)
	exec splint -weak +quiet -unrecog ../hmstl.c -I/usr/local/include
} -result {}

test static-splint-2 {
# splint heightmap
} -constraints {
	static
	has_splint
} -body {
	exec splint -weak +quiet ../heightmap.c
} -result {}

test static-cppcheck-1 {
# Check that CPPCheck reports no issues.
} -constraints {
	static
	has_cppcheck
} -body {
	exec cppcheck --enable=all --quiet ../hmstl.c
} -result {}

test static-cppcheck-2 {
# cppcheck heightmap
} -constraints {
	static
	has_cppcheck
} -body {
	exec cppcheck --enable=all --quiet ../heightmap.c
} -result {}

test static-clang-1 {
# Check that Clang's analyzer reports no issues.
} -constraints {
	static
	has_clang
} -body {
	exec clang --analyze ../hmstl.c
} -cleanup {
	# Remove diagnostics file generated by clang
	file delete hmstl.plist
} -result {}

test static-clang-2 {
# clang analyze heightmap
} -constraints {
	static
	has_clang
} -body {
	exec clang --analyze ../heightmap.c
} -cleanup {
	file delete heightmap.plist
} -result {}

::tcltest::cleanupTests
