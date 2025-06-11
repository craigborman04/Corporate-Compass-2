# Corporate Compass

A modern SaaS application for managing corporate hierarchies, strategic goals, and performance reviews. Built with Next.js and Supabase.

## Technologies

- **Framework:** Next.js (App Router)
- **Backend:** Supabase (Auth, Postgres DB, Storage)
- **Styling:** Tailwind CSS
- **UI Components:** shadcn/ui
- **State Management:** React Context API

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/craigborman04/Corporate-Compass-2.git
   cd corporate-compass
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   - Copy `.env.local.example` to `.env.local`
   - Add your Supabase project URL and anon key:
     ```
     NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
     NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. Run the development server:
   ```bash
   npm run dev
   ```

5. Open [http://localhost:3000](http://localhost:3000) in your browser.

## Project Structure

```
corporate-compass/
├── src/
│   ├── app/              # Next.js App Router pages
│   ├── components/       # React components
│   │   ├── ui/          # shadcn/ui components
│   │   └── ...          # Custom components
│   ├── hooks/           # Custom React hooks
│   ├── lib/             # Utilities and configurations
│   └── types/           # TypeScript type definitions
├── supabase/
│   └── migrations/      # Database migrations
├── public/              # Static assets
└── docs/               # Project documentation
```

## Features

- **Authentication & Authorization**
  - Role-based access control (Owner, Administrator, Director, Manager)
  - Protected routes and API endpoints

- **Organizational Hierarchy**
  - Holding Companies
  - Subsidiaries
  - Divisions

- **Strategic Management**
  - Goal setting and tracking
  - Performance reviews
  - Reports and analytics

## Development

- Run tests: `npm test`
- Lint code: `npm run lint`
- Build for production: `npm run build`

## Contributing

1. Create a feature branch: `git checkout -b feature/amazing-feature`
2. Commit your changes: `git commit -m 'feat: add amazing feature'`
3. Push to the branch: `git push origin feature/amazing-feature`
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
