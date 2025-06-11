import type { Metadata } from 'next'
import './globals.css'
import { Inter } from 'next/font/google'
import { ClientLayout } from './client-layout'
import { UserProvider } from '@/hooks/use-user'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Corporate Compass',
  description: 'Manage your corporate hierarchy, strategic goals, and performance reviews',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <UserProvider>
          <ClientLayout>
            {children}
          </ClientLayout>
        </UserProvider>
      </body>
    </html>
  )
} 