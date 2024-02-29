docs:
	@sourcedocs generate --min-acl private -r --spm-module Localized --output-folder Documentation/Localized
	@sourcedocs generate --min-acl private -r --spm-module LocalizedMacros --output-folder Documentation/LocalizedMacros

swiftlint:
	@swiftlint --autocorrect
