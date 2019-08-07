package com.xatkit.language.execution;

import static java.util.Objects.nonNull;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.EObject;

import com.xatkit.execution.ExecutionModel;
import com.xatkit.intent.Context;
import com.xatkit.intent.EventDefinition;
import com.xatkit.intent.Library;
import com.xatkit.platform.EventProviderDefinition;
import com.xatkit.platform.PlatformDefinition;
import com.xatkit.utils.ImportRegistry;

/**
 * A set of utility methods to manipulate Execution models.
 */
public class ExecutionUtils {

	/**
	 * Returns the {@link ExecutionModel} containing the provided {@code element}.
	 * 
	 * @param element the {@link EObject} to retrieve the containing {@link ExecutionModel} of
	 * @return the retrieved {@link ExecutionModel} if it exists, {@code null} otherwise
	 * 
	 * @see #getContaining(EObject, Class)
	 */
	public static ExecutionModel getContainingExecutionModel(EObject element) {
		return getContaining(element, ExecutionModel.class);
	}

	/**
	 * Returns the {@link EventDefinition} containing the provided {@code element}.
	 * 
	 * @param element the {@link EObject} to retrieve the containing {@link EventDefinition} of
	 * @return the retrieved {@link EventDefinition} if it exists, {@code null} otherwise
	 * 
	 * @see #getContaining(EObject, Class)
	 */
	public static EventDefinition getContainingEventDefinition(EObject element) {
		return getContaining(element, EventDefinition.class);
	}

	/**
	 * Returns the {@link Library} containing the provided {@code element}.
	 * 
	 * @param element the {@link EObject} to retrieve the containing {@link Library} of
	 * @return the retrieved {@link Library} if it exists, {@code null} otherwise
	 * 
	 * @see #getContaining(EObject, Class)
	 */
	public static Library getContainingLibrary(EObject element) {
		return getContaining(element, Library.class);
	}

	/**
	 * Returns the {@link PlatformDefinition} containing the provided {@code element}.
	 * 
	 * @param element the {@link EObject} to retrieve the containing {@link PlatformDefinition} of
	 * @return the retrieved {@link PlatformDefinition} if it exists, {@code null} otherwise
	 * 
	 * @see #getContaining(EObject, Class)
	 */
	public static PlatformDefinition getContainingPlatform(EObject element) {
		return getContaining(element, PlatformDefinition.class);
	}

	/**
	 * Returns the {@code containerType} element containing the provided {@code element}.
	 * <p>
	 * This method returns the first {@code containerType} instance in the provided {@code element}'s {@code eContainer}
	 * hierarchy.
	 * 
	 * @param element the {@link EObject} to retrieve the containing {@code containerType} of
	 * @param containerType the type of the container element to retrieve
	 * @return the containing {@code containerType} instance if it exists, {@code null} otherwise
	 */
	private static <T> T getContaining(EObject element, Class<T> containerType) {
		EObject currentObject = element;
		while (nonNull(currentObject)) {
			currentObject = currentObject.eContainer();
			if (containerType.isInstance(currentObject)) {
				return (T) currentObject;
			}
		}
		return null;
	}

	/**
	 * Returns the {@link EventDefinition}s from the imported {@link Platform} and {@link Library} instances.
	 * 
	 * @param executionModel the {@link ExecutionModel} containing the imports to look at
	 * @return the retrieved {@link EventDefinition}
	 * 
	 * @see #getEventDefinitionsFromImportedLibraries(ExecutionModel)
	 * @see #getEventDefinitionsFromImportedPlatforms(ExecutionModel)
	 */
	public static Collection<EventDefinition> getEventDefinitionsFromImports(ExecutionModel executionModel) {
		Collection<EventDefinition> result = getEventDefinitionsFromImportedLibraries(executionModel);
		result.addAll(getEventDefinitionsFromImportedPlatforms(executionModel));
		return result;
	}

	/**
	 * Returns the {@link EventDefinition}s from the imported {@link Library} instances.
	 * 
	 * @param executionModel the {@link ExecutionModel} containing the imports to look at
	 * @return the retrieved {@link EventDefinition}s
	 * @see #getEventDefinitionsFromImportedPlatforms(ExecutionModel)
	 */
	public static Collection<EventDefinition> getEventDefinitionsFromImportedLibraries(ExecutionModel executionModel) {
		List<EventDefinition> eventDefinitions = new ArrayList<>();
		Collection<Library> libraries = ImportRegistry.getInstance().getImportedLibraries(executionModel);
		for (Library library : libraries) {
			eventDefinitions.addAll(library.getEventDefinitions());
		}
		return eventDefinitions;
	}

	/**
	 * Returns the {@link EventDefinition}s from the imported {@link Platform}s.
	 * 
	 * @param executionModel the {@link ExecutionModel} containing the imports to look at
	 * 
	 * @return the retrieved {@link EventDefinition}s
	 * @see #getEventDefinitionsFromImportedLibraries(ExecutionModel)
	 */
	public static Collection<EventDefinition> getEventDefinitionsFromImportedPlatforms(ExecutionModel executionModel) {
		List<EventDefinition> eventDefinitions = new ArrayList<>();
		Collection<PlatformDefinition> platformDefinitions = ImportRegistry.getInstance()
				.getImportedPlatforms(executionModel);
		for (PlatformDefinition platformDefinition : platformDefinitions) {
			for (EventProviderDefinition eventProviderDefinition : platformDefinition.getEventProviderDefinitions()) {
				eventDefinitions.addAll(eventProviderDefinition.getEventDefinitions());
			}
		}
		return eventDefinitions;
	}

	/**
	 * Returns the {@link EventDefinition} from the imported {@link Library} instances matching the provided
	 * {@code eventDefinitionName}.
	 * 
	 * @param executionModel the {@link ExecutionModel} containing the imports to look at
	 * @param eventDefinitionName the name of the {@link EventDefinition} to retrieve
	 * @return the retrieved {@link EventDefinition} if it exists, {@code null} otherwise
	 */
	public static EventDefinition getEventDefinitionFromImportedLibraries(ExecutionModel executionModel,
			String eventDefinitionName) {
		Optional<EventDefinition> result = getEventDefinitionsFromImportedLibraries(executionModel).stream()
				.filter(e -> e.getName().equals(eventDefinitionName)).findAny();
		return result.orElseGet(() -> null);
	}

	/**
	 * Returns the {@link EventDefinition} from the imported {@link Platform}s matching the provided
	 * {@code eventDefinitionName}.
	 * 
	 * @param executionModel the {@link ExecutionModel} containing the imports to look at
	 * @param eventDefinitionName the name of the {@link EventDefinition} to retrieve
	 * @return the retrieved {@link EventDefinition} if it exists, {@code null} otherwise
	 */
	public static EventDefinition getEventDefinitionFromImportedPlatforms(ExecutionModel executionModel,
			String eventDefinitionName) {
		Optional<EventDefinition> result = getEventDefinitionsFromImportedPlatforms(executionModel).stream()
				.filter(e -> e.getName().equals(eventDefinitionName)).findAny();
		return result.orElseGet(() -> null);
	}

	/**
	 * Returns the {@link EventProviderDefinition}s from the imported {@link Platform}s.
	 * 
	 * @param executionModel the {@link ExecutionModel} containing the imports to look at
	 * @return the retrieved {@link EventProviderDefinition}s
	 */
	public static Collection<EventProviderDefinition> getEventProviderDefinitionsFromImportedPlatforms(
			ExecutionModel executionModel) {
		List<EventProviderDefinition> eventProviderDefinitions = new ArrayList<>();
		Collection<PlatformDefinition> platformDefinitions = ImportRegistry.getInstance()
				.getImportedPlatforms(executionModel);
		for (PlatformDefinition platformDefinition : platformDefinitions) {
			eventProviderDefinitions.addAll(platformDefinition.getEventProviderDefinitions());
		}
		return eventProviderDefinitions;
	}

	/**
	 * Returns the out {@link Context} from the imported {@link Platform} and {@link Library} instances.
	 * <p>
	 * This method returns {@link EventDefinition}'s out {@link Context} and {@link EventProviderDefinition} out
	 * {@link Context}.
	 * 
	 * @param executionModel the {@link ExecutionModel} containing the imports to look at
	 * @return the retrieved {@link Context} instances
	 */
	public static Collection<Context> getOutContextsFromImports(ExecutionModel executionModel) {
		List<Context> results = new ArrayList<Context>();
		for (EventDefinition eventDefinition : getEventDefinitionsFromImports(executionModel)) {
			results.addAll(eventDefinition.getOutContexts());
		}
		/*
		 * Add the out contexts created by the EventProviderDefinitions (defined at the provider level)
		 */
		for (EventProviderDefinition eventProvider : getEventProviderDefinitionsFromImportedPlatforms(executionModel)) {
			results.addAll(eventProvider.getOutContexts());
		}
		return results;
	}
}
