# How to contribute to ATAG

The ATAG project does not have dedicated developers, we count on **YOU** to
contribute to the test case library, to add tests and to report (and
fix) bugs.

If you have ACI tests needed to support your project's demand and you feel
that your colleagues can benefit from it, please share it so that we can add
it to the ATAG test case library.

**YOU** can contribute to ATAG in multiple ways ranging from submitting test
case ideas and/or enhancements to coding test cases.

Any contribution is welcome and highly appreciated as the tool is intended as a
community effort.

# How to contribute test case ideas

1. Navigate to the ATAG repository at <https://wwwin-github.cisco.com/AS-Community/ATAG>
and click on the "Issues" tab on the top left.
2. Click on the "New Issue" button on top right. Provide a title and a short
description of your test case idea. **Before** submitting your idea, make sure to
associate the label "enhancement" to your idea, which is done by clicking on the
gear icon next to "Labels" in the navigation bar on the left of the screen.
3. Lastly, submit your test case idea by clicking on the "Submit new issue" button
at the bottom of the screen.

## How to contribute test cases

Creating new test case templates in ATAG requires knowledge with ACI's
REST API as well as basic knowledge about how to write RASTA/CXTA tests.
You do not need to be a seasoned programmer in order to contribute.

1. Please create a fork of the ATAG repository. Navigate to
<https://wwwin-github.cisco.com/AS-Community/ATAG> and click on the "Fork" icon
on the top right. In most cases you want to create the fork in your local space
(@username)
2. Clone this forked repository and create a new branch with a name that reflects
the topic of the changes (e.g. bugfix/issue or feature/new_feature)
1. Make the changes as you want to see them reflected in the target
distribution (i.e. add/change files)
4. Test your code/test cases to make sure it works and that it has not broken
any existing functionality
5. Only commit the changes you want to be reflected (i.e. if you made changes
to existing templates to make them run in your environment, please don't add
them to the commit)
6. Commit the changes with a proper comment so we can see what you have
contributed
7. Before creating a pull request, please sync your fork to the main repository
to ensure you pick up changes made by others. This will help to avoid merge
conflicts later on
8. Test your code again
9. Push your branch to your forked repository
10. Create a pull request against the development ATAG branch, this will start
a code review process with the ATAG core team
11. Work with the core team to address their feedback and comments
12. Wait to see your changes be merged first into the ATAG development branch,
subsequent to the master branch and included for all to benefit from

If you have questions during the process, feel free to join the ATAG Webex
Teams room (<https://eurl.io/#SJJfoqILV>) or send an email to the support
mailing-list <atag-cx-tool@cisco.com>

We are happy to add active and trusted contributors as developers to the main
ATAG repository so you can also contribute by creating a branch on the repo
and creating a pull request there, instead of working off a fork.

## Maintainers & Code Review Process

The following people are core maintainers and need to approve any commit
into the master branch:

* Morten Skriver
