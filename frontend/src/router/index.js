import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'

const normalizeBase = (value) => {
  const v = typeof value === 'string' ? value : '/'
  if (v.startsWith('http://') || v.startsWith('https://')) {
    try {
      const u = new URL(v)
      return u.pathname || '/'
    } catch {
      return '/'
    }
  }
  return v.startsWith('/') ? v : `/${v}`
}

const router = createRouter({
  history: createWebHistory(normalizeBase(import.meta.env.BASE_URL)),
  routes: [
    {
      path: '/',
      name: 'landing',
      component: () => import('@/views/LandingView.vue'),
      meta: { requiresAuth: false },
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { requiresAuth: false },
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('@/views/RegisterView.vue'),
      meta: { requiresAuth: false },
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: () => import('@/views/DashboardView.vue'),
      meta: { requiresAuth: true },
    },
  ],
})

// Guardia de navegación global
router.beforeEach((to, from, next) => {
  if (to.path.startsWith('http://') || to.path.startsWith('https://')) {
    next('/')
    return
  }
  const authStore = useAuthStore()
  const requiresAuth = to.matched.some((record) => record.meta.requiresAuth)

  if (requiresAuth && !authStore.isAuthenticated) {
    // Ruta requiere autenticación pero el usuario no está autenticado
    next('/login')
  } else if (!requiresAuth && authStore.isAuthenticated && (to.name === 'login' || to.name === 'register')) {
    // Usuario autenticado intenta acceder a login/register
    next('/dashboard')
  } else {
    next()
  }
})

export default router
