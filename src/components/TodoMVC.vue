<!--
A fully spec-compliant TodoMVC implementation
https://todomvc.com/
-->

<script lang="ts">
import { defineComponent } from 'vue';
import Todo from '../models/Todo';

const STORAGE_KEY = 'vue-todomvc'

interface Filter {
  all(todos: Todo[]) : Todo[],
  active(todos: Todo[]) : Todo[],
  completed(todos: Todo[]) : Todo[],
}

const filters: Filter = {
  all: todos => todos,
  active: todos => todos.filter((todo) => !todo.completed),
  completed: todos => todos.filter((todo) => todo.completed)
}

export default defineComponent ({
  // app initial state
  data: () => ({
    todos: JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]') as Todo[],
    editedTodo: null as (Todo | null),
    visibility: 'all' as string,
    beforeEditCache: '',
  }),

  // watch todos change for localStorage persistence
  watch: {
    todos: {
      handler(todos: Todo[]) {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(todos))
      },
      deep: true
    }
  },

  mounted() {
    window.addEventListener('hashchange', this.onHashChange)
    this.onHashChange()
  },

  computed: {
    filteredTodos(): Todo[] {
      return filters[this.visibility as keyof Filter](this.todos)
    },
    remaining(): number {
      return filters.active(this.todos).length
    }
  },

  // methods that implement data logic.
  // note there's no DOM manipulation here at all.
  methods: {
    toggleAll(e: any): void {
      if (e == null) {}
      this.todos.forEach((todo) => (todo.completed = e.target.checked))
    },

    addTodo(e: any): void {
      const value = e.target.value.trim()
      if (!value) {
        return
      }
      this.todos.push({
        id: Date.now(),
        title: value,
        completed: false
      })
      e.target.value = ''
    },

    removeTodo(todo: Todo): void {
      this.todos.splice(this.todos.indexOf(todo), 1)
    },

    editTodo(todo: Todo): void {
      this.beforeEditCache = todo.title
      this.editedTodo = todo
    },

    doneEdit(todo: Todo): void {
      if (!this.editedTodo) {
        return
      }
      this.editedTodo = null
      todo.title = todo.title.trim()
      if (!todo.title) {
        this.removeTodo(todo)
      }
    },

    cancelEdit(todo: Todo): void {
      this.editedTodo = null
      todo.title = this.beforeEditCache
    },

    removeCompleted(): void {
      this.todos = filters.active(this.todos)
    },

    onHashChange(): void {
      var visibility: string = window.location.hash.replace(/#\/?/, '')
      if (filters[visibility as keyof Filter]) {
        this.visibility = visibility
      } else {
        window.location.hash = ''
        this.visibility = 'all'
      }
    }
  }
});
</script>

<template>
  <section class="todoapp">
    <header class="header">
      <h1>todos</h1>
      <input
        class="new-todo"
        autofocus
        placeholder="What needs to be done?"
        @keyup.enter="addTodo"
      />
    </header>
    <section class="main" v-if="todos.length">
      <input
        id="toggle-all"
        class="toggle-all"
        type="checkbox"
        :checked="remaining === 0"
        @change="toggleAll"
      />
      <label for="toggle-all">Mark all as complete</label>
      <ul class="todo-list">
        <li
          v-for="todo in filteredTodos"
          class="todo"
          :key="todo.id"
          :class="{ completed: todo.completed, editing: todo === editedTodo }"
        >
          <div class="view">
            <label for="toggle-done">done</label>
            <input id="toggle-done" class="toggle" type="checkbox" v-model="todo.completed" />
            <label @dblclick="editTodo(todo)">{{ todo.title }}</label>
            <button class="destroy" @click="removeTodo(todo)"></button>
          </div>
          <input
            v-if="todo === editedTodo"
            class="edit"
            type="text"
            v-model="todo.title"
            @vnode-mounted="({ el } : { el: any} ) => el.focus()"
            @blur="doneEdit(todo)"
            @keyup.enter="doneEdit(todo)"
            @keyup.escape="cancelEdit(todo)"
          />
        </li>
      </ul>
    </section>
    <footer class="footer">
      <span class="todo-count">
        <strong>{{ remaining }}</strong>
        <span>{{ remaining === 1 ? 'item' : 'items' }} left</span>
      </span>
      <ul class="filters">
        <li>
          <a href="#/all" :class="{ selected: visibility === 'all' }">All</a>
        </li>
        <li>
          <a href="#/active" :class="{ selected: visibility === 'active' }">Active</a>
        </li>
        <li>
          <a href="#/completed" :class="{ selected: visibility === 'completed' }">Completed</a>
        </li>
      </ul>
      <button class="clear-completed" @click="removeCompleted" v-if="todos.length > remaining">
        Clear completed
      </button>
    </footer>
  </section>
</template>

<style>
@import "./TodoMVC.css";
</style>
