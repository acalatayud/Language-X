#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../Compiler/nodes.h"
#include "typeChecks.h"

functionList * functions = NULL;
variableList * defines;
functionNode * current;

functionList * getFunctionList() {
  return functions;
}

void createFunction(char * name) {
	if(functionExists(name)) {
		printError(FUNCTION_REPETITION_ERROR);
	}

	functionNode * function = malloc(sizeof(functionNode));
	function->name = malloc(strlen(name) + 1);
	strcpy(function->name, name);
	function->returnType = UNKNOWN;
	function->parameters = NULL;
	function->variables = NULL;

	addToList(function, functions);
	current = function;
}

void addToList(functionNode * function, functionList * list) {
  functionList * node = malloc(sizeof(functionList));
  node->function = function;
  node->next = list;
	list = node;
}

int addReturn(variableType type) {
  if(current->returnType != UNKNOWN && current->returnType != type)
    return 0;
  current->returnType = type;
  return 1;
}

int addParameterToFunction(char * name) {
  if(parameterExists(name))
    return 0;

  variableList * node = malloc(sizeof(variableList));
  node->variable = createVariable(name, UNKNOWN, UNKNOWN);
  node->next = current->parameters;
  current->parameters = node;

  return 1;
}

void addToDefines(char * name, variableType type) {
  variableList * node = malloc(sizeof(variableList));
  node->variable = createVariable(name, type, VOID);
  node->next = defines;
  defines = node;
}

int existsDefine(char * name) {
  variableNode * ret = getVariableFromList(name, defines);
  if(ret != NULL)
    return 1;
}

variableNode * createVariable(char * name, variableType type, variableType elementType) {
  variableNode * variable = malloc(sizeof(variableNode));
  variable->name = malloc(strlen(name) + 1);
	strcpy(variable->name, name);
	variable->type = type;
  variable->elementType = elementType;

  return variable;
}

int addVariable(char * name, variableType type) {
  int exists = existsVariableTyped(name, type);
  if(exists == TYPE_DEFINED) {
    return 1;
  } else if(exists == INCOMPATIBLE_DEFINITION)
    return 0;

  variableList * node = malloc(sizeof(variableList));
  node->variable = createVariable(name, type, UNKNOWN);
  node->next = current->variables;
  current->variables = node;

  return 1;
}

int parameterExists(char * name) {
  variableNode * ret = getVariableFromList(name, defines);
  if(ret != NULL)
    return 1;
  variableNode * ret = getVariableFromList(name, current->parameters);
  return ret != NULL;
}

functionNode * getFunction(char * name) {
  functionList * next = functionList;
  while(next != NULL) {
    functionNode * function = next->function;
    if(strcmp(function->name, name) == 0)
      return function;
    next = next->next;
  }
  return NULL;
}

variableNode * getVariable(char * name, functionNode * function) {
  variableNode * ret = getVariableFromList(name, defines);
  if(ret != NULL)
    return ret;
  variableNode * ret = getVariableFromList(name, function->parameters);
  if(ret != NULL)
    return ret;
  variableNode * ret = getVariableFromList(name, function->variables);
  return ret;
}

variableNode * getVariableFromList(char * name, variableList * list) {
  variableList * next = list;
  while(next != NULL) {
    variableNode * variable = next->variable;
    if(strcmp(variable->name, name) == 0)
      return variable;
    next = next->next;
  }
  return NULL;
}

int existsVariableTyped(char * name, variableType type) {
  variableNode * ret = getVariableFromList(name, function->parameters);
  if(ret != NULL) {
    if(ret->type == UNKNOWN || ret->type == type) {
      ret->type = type;
      return TYPE_DEFINED;
    }
    return INCOMPATIBLE_DEFINITION;
  }
  variableNode * ret = getVariableFromList(name, function->variables);
  if(ret != NULL) {
    if(ret->type == UNKNOWN || ret->type == type) {
      ret->type = type;
      return TYPE_DEFINED;
    }
    return INCOMPATIBLE_DEFINITION;
  }
  return 0;
}

int existsVariable(char * name) {
  variableNode * ret = getVariableFromList(name, function->parameters);
  if(ret != NULL)
    return 1;
  variableNode * ret = getVariableFromList(name, function->variables);
  return ret != NULL;
}