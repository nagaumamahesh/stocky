# Stocky Frontend

React frontend application for the Stocky stock rewards platform.

## Features

- **Dashboard**: Overview of portfolio value, today's rewards, and statistics
- **Portfolio**: Detailed view of all stock holdings with current values
- **Rewards**: List of all stock rewards received
- **History**: Historical portfolio value visualization with charts
- **Admin Dashboard**: Create new stock rewards (admin only)
- **Role-Based Access**: MVP role-based access control (user/admin)

## Tech Stack

- React 18.2
- React Router 6
- Axios for API calls
- Recharts for data visualization
- CSS3 for styling

## Setup

### Prerequisites

- Node.js 16+ and npm
- Backend API running on `http://localhost:8080`

### Installation

1. Install dependencies:
```bash
cd frontend
npm install
```

2. Create a `.env` file (optional):
```env
REACT_APP_API_URL=http://localhost:8080/api/v1
```

3. Start the development server:
```bash
npm start
```

The app will open at `http://localhost:3000`

## Usage

### Login

For MVP, the login system uses sample user IDs:

- **Regular Users**: Use UUIDs from the database (e.g., `11111111-1111-1111-1111-111111111111`)
- **Admin**: Use `admin-1111-1111-1111-111111111111` or set role to "admin" in login form

### Sample User IDs

- `11111111-1111-1111-1111-111111111111` - Rahul Sharma
- `22222222-2222-2222-2222-222222222222` - Priya Patel
- `33333333-3333-3333-3333-333333333333` - Amit Kumar
- `44444444-4444-4444-4444-444444444444` - Neha Singh
- `55555555-5555-5555-5555-555555555555` - Vikram Reddy

### Pages

- **Dashboard** (`/dashboard`): Overview of portfolio and today's rewards
- **Portfolio** (`/portfolio`): Detailed holdings view
- **Rewards** (`/rewards`): List of all rewards
- **History** (`/history`): Historical portfolio value chart
- **Admin** (`/admin`): Create new rewards (admin only)

## Project Structure

```
frontend/
├── public/
│   └── index.html
├── src/
│   ├── components/
│   │   ├── Layout.js
│   │   ├── Layout.css
│   │   └── PrivateRoute.js
│   ├── contexts/
│   │   └── AuthContext.js
│   ├── pages/
│   │   ├── Login.js
│   │   ├── Dashboard.js
│   │   ├── Portfolio.js
│   │   ├── Rewards.js
│   │   ├── History.js
│   │   └── AdminDashboard.js
│   ├── services/
│   │   └── api.js
│   ├── App.js
│   ├── App.css
│   ├── index.js
│   └── index.css
└── package.json
```

## API Integration

The frontend communicates with the backend API at `/api/v1`:

- `POST /reward` - Create reward (admin)
- `GET /today-stocks/:userId` - Get today's stocks
- `GET /portfolio/:userId` - Get portfolio
- `GET /stats/:userId` - Get user stats
- `GET /historical-inr/:userId` - Get historical data

## Role-Based Access

### User Role
- Access to Dashboard, Portfolio, Rewards, History
- Can view their own data

### Admin Role
- All user permissions
- Access to Admin Dashboard
- Can create rewards for any user

## Building for Production

```bash
npm run build
```

This creates an optimized production build in the `build` folder.

## Future Enhancements

- Real authentication with JWT tokens
- User registration
- Password reset
- Email notifications
- Real-time updates
- Advanced filtering and search
- Export data functionality
- Mobile app

