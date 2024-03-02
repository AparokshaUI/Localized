docs:
	@sourcedocs generate --min-acl private -r --spm-module Localized --output-folder Documentation/Localized
	@sourcedocs generate --min-acl private -r --spm-module LocalizedMacros --output-folder Documentation/LocalizedMacros
	@sourcedocs generate --min-acl private -r --spm-module Generation --output-folder Documentation/Generation
	@sourcedocs generate --min-acl private -r --spm-module GenerationLibrary --output-folder Documentation/GenerationLibrary

swiftlint:
	@swiftlint --autocorrect
