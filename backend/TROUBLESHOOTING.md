# Troubleshooting Guide

## Frontend "Failed to load dashboard data" Error

### Common Causes and Solutions

#### 1. CORS Issues (Most Common)
**Symptom**: Browser console shows CORS errors like "Access to XMLHttpRequest blocked by CORS policy"

**Solution**: 
- Ensure the backend has CORS middleware enabled (already added in main.go)
- Run `go mod tidy` in the backend directory to download dependencies
- Restart the backend server

#### 2. Backend Not Running
**Symptom**: Network error or "Cannot connect to backend"

**Solution**:
- Check if backend is running on `http://localhost:8080`
- Test with: `curl http://localhost:8080/health`
- Start backend: `cd backend && go run main.go`

#### 3. Database Connection Issues
**Symptom**: Backend logs show database connection errors

**Solution**:
- Verify `.env` file has correct database credentials
- Check Azure SQL Server firewall rules allow your IP
- Test database connection manually

#### 4. Invalid User ID
**Symptom**: API returns 400 Bad Request or 404 Not Found

**Solution**:
- Use valid UUIDs from the sample data
- Ensure user exists in the database
- Check user ID format (must be valid UUID)

#### 5. Missing Data
**Symptom**: Dashboard loads but shows empty data

**Solution**:
- Run the sample data SQL script in Azure SQL Server
- Verify users have reward events in the database
- Check that stock prices are populated

### Debugging Steps

1. **Check Browser Console**:
   - Open browser DevTools (F12)
   - Check Console tab for detailed error messages
   - Check Network tab to see API request/response

2. **Check Backend Logs**:
   - Look for error messages in backend terminal
   - Check for database query errors
   - Verify API endpoints are being hit

3. **Test API Directly**:
   ```bash
   # Test health endpoint
   curl http://localhost:8080/health
   
   # Test stats endpoint (replace with valid user ID)
   curl http://localhost:8080/api/v1/stats/11111111-1111-1111-1111-111111111111
   ```

4. **Verify User ID**:
   - Check localStorage in browser DevTools
   - Verify user object has `id` field
   - Ensure ID is a valid UUID format

### Quick Fixes

1. **Restart Both Servers**:
   ```bash
   # Backend
   cd backend
   go mod tidy
   go run main.go
   
   # Frontend (in new terminal)
   cd frontend
   npm start
   ```

2. **Clear Browser Cache**:
   - Clear localStorage
   - Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
   - Try incognito/private mode

3. **Check Environment Variables**:
   - Backend: Verify `.env` file exists and has correct values
   - Frontend: Check if `REACT_APP_API_URL` is set (optional)

### Sample User IDs for Testing

- `11111111-1111-1111-1111-111111111111` - Rahul Sharma
- `22222222-2222-2222-2222-222222222222` - Priya Patel
- `33333333-3333-3333-3333-333333333333` - Amit Kumar

Make sure these users exist in your database by running the sample_data.sql script.

