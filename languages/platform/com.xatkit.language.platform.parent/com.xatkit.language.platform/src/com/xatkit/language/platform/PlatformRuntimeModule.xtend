/*
 * generated by Xtext 2.12.0
 */
package com.xatkit.language.platform


/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class PlatformRuntimeModule extends AbstractPlatformRuntimeModule {
	
	override bindILinkingService() {
		return PlatformLinkingService
	}
}
