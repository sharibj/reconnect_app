#!/bin/bash

# Reconnect App - Dummy Data Loader Script
# This script populates the backend with realistic sample data

API_BASE_URL="http://localhost:8080/api"
AUTH_URL="$API_BASE_URL/auth"
RECONNECT_URL="$API_BASE_URL/reconnect"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Reconnect App - Dummy Data Loader${NC}"
echo "=================================================="

# Check if server is running
echo -e "${YELLOW}🔍 Checking if backend server is running...${NC}"
server_check=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE_URL/auth/login" || echo "000")

if [[ $server_check == "000" ]]; then
    echo -e "${RED}❌ Backend server is not responding at $API_BASE_URL${NC}"
    echo -e "${YELLOW}💡 Make sure your backend server is running on localhost:8080${NC}"
    exit 1
elif [[ $server_check == "404" ]]; then
    echo -e "${RED}❌ Auth endpoint not found. Check if the server is running the correct API${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Backend server is responding${NC}"
fi

# Function to make API calls with error handling
make_api_call() {
    local method=$1
    local url=$2
    local data=$3
    local description=$4

    echo -e "${YELLOW}📡 $description...${NC}"

    if [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $JWT_TOKEN" \
            -d "$data")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $JWT_TOKEN")
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [[ $http_code -ge 200 && $http_code -lt 300 ]]; then
        echo -e "${GREEN}✅ Success: $description${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed: $description (HTTP $http_code)${NC}"
        echo -e "${RED}Response: $body${NC}"
        return 1
    fi
}

# Step 1: Register a test user
echo -e "\n${BLUE}👤 Step 1: Creating test user...${NC}"
register_response=$(curl -s -w "\n%{http_code}" -X POST "$AUTH_URL/register" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "password": "password123",
        "email": "test@reconnect.app"
    }')

register_http_code=$(echo "$register_response" | tail -n1)
register_body=$(echo "$register_response" | sed '$d')

if [[ $register_http_code -ge 200 && $register_http_code -lt 300 ]]; then
    echo -e "${GREEN}✅ User registered successfully${NC}"
    echo "Register response: $register_body"
    JWT_TOKEN=$(echo "$register_body" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])" 2>/dev/null)
elif [[ $register_http_code -eq 409 ]] || [[ $register_http_code -eq 400 ]]; then
    echo -e "${YELLOW}⚠️ User already exists, logging in...${NC}"

    # Login with existing user
    login_response=$(curl -s -w "\n%{http_code}" -X POST "$AUTH_URL/login" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "testuser",
            "password": "password123"
        }')

    login_http_code=$(echo "$login_response" | tail -n1)
    login_body=$(echo "$login_response" | sed '$d')

    if [[ $login_http_code -ge 200 && $login_http_code -lt 300 ]]; then
        echo -e "${GREEN}✅ Login successful${NC}"
        echo "Login response: $login_body"
        JWT_TOKEN=$(echo "$login_body" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])" 2>/dev/null)
    else
        echo -e "${RED}❌ Login failed (HTTP $login_http_code)${NC}"
        echo "Login response: $login_body"
        exit 1
    fi
else
    echo -e "${RED}❌ Registration failed (HTTP $register_http_code)${NC}"
    echo "Register response: $register_body"
    exit 1
fi

if [[ -z "$JWT_TOKEN" ]]; then
    echo -e "${RED}❌ Failed to extract JWT token${NC}"
    exit 1
fi

echo -e "🔑 JWT Token obtained: ${JWT_TOKEN:0:20}..."

# Validate token by making a test API call
echo -e "${YELLOW}🔐 Validating JWT token...${NC}"
token_test=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$RECONNECT_URL/groups?page=0&size=1" \
    -H "Authorization: Bearer $JWT_TOKEN")

if [[ $token_test -ge 200 && $token_test -lt 300 ]]; then
    echo -e "${GREEN}✅ JWT token is valid${NC}"
else
    echo -e "${RED}❌ JWT token validation failed (HTTP $token_test)${NC}"
    exit 1
fi

# Step 2: Create Groups
echo -e "\n${BLUE}👥 Step 2: Creating groups...${NC}"

groups=(
    '{"name": "Family", "frequencyInDays": 7}'
    '{"name": "Close Friends", "frequencyInDays": 14}'
    '{"name": "Work Colleagues", "frequencyInDays": 30}'
    '{"name": "Acquaintances", "frequencyInDays": 60}'
    '{"name": "Mentors", "frequencyInDays": 21}'
    '{"name": "College Friends", "frequencyInDays": 45}'
    '{"name": "Neighbors", "frequencyInDays": 90}'
)

for group in "${groups[@]}"; do
    group_name=$(echo "$group" | grep -o '"name": *"[^"]*' | cut -d'"' -f4)
    make_api_call "POST" "$RECONNECT_URL/groups" "$group" "Creating group: $group_name"
done

# Step 3: Create Contacts
echo -e "\n${BLUE}👨‍👩‍👧‍👦 Step 3: Creating contacts...${NC}"

contacts=(
    '{
        "nickName": "Mom",
        "group": "family",
        "details": {
            "firstName": "Sarah",
            "lastName": "Johnson",
            "notes": "Always calls on Sundays. Loves gardening and cooking.",
            "contactInfo": {
                "email": "sarah.johnson@email.com",
                "phone": "+1-555-0101",
                "address": "123 Maple Street, Springfield, IL 62701"
            }
        }
    }'
    '{
        "nickName": "Dad",
        "group": "family",
        "details": {
            "firstName": "Michael",
            "lastName": "Johnson",
            "notes": "Retired engineer. Enjoys woodworking and fishing.",
            "contactInfo": {
                "email": "mike.johnson@email.com",
                "phone": "+1-555-0102",
                "address": "123 Maple Street, Springfield, IL 62701"
            }
        }
    }'
    '{
        "nickName": "Alex",
        "group": "close friends",
        "details": {
            "firstName": "Alexandra",
            "lastName": "Chen",
            "notes": "Best friend from college. Software engineer at Google. Loves hiking.",
            "contactInfo": {
                "email": "alex.chen@gmail.com",
                "phone": "+1-555-0201",
                "address": "456 Tech Lane, San Francisco, CA 94105"
            }
        }
    }'
    '{
        "nickName": "Jake",
        "group": "close friends",
        "details": {
            "firstName": "Jacob",
            "lastName": "Williams",
            "notes": "Childhood friend. Teacher at local high school. Great at board games.",
            "contactInfo": {
                "email": "jake.williams@school.edu",
                "phone": "+1-555-0202",
                "address": "789 Oak Avenue, Chicago, IL 60601"
            }
        }
    }'
    '{
        "nickName": "Emma",
        "group": "work colleagues",
        "details": {
            "firstName": "Emma",
            "lastName": "Davis",
            "notes": "Project manager on the mobile team. Very organized and detail-oriented.",
            "contactInfo": {
                "email": "emma.davis@company.com",
                "phone": "+1-555-0301",
                "address": "321 Business Blvd, New York, NY 10001"
            }
        }
    }'
    '{
        "nickName": "Dr. Smith",
        "group": "mentors",
        "details": {
            "firstName": "Robert",
            "lastName": "Smith",
            "notes": "Former professor and career mentor. Expert in computer science.",
            "contactInfo": {
                "email": "r.smith@university.edu",
                "phone": "+1-555-0401",
                "address": "555 University Drive, Boston, MA 02101"
            }
        }
    }'
    '{
        "nickName": "Lisa",
        "group": "college friends",
        "details": {
            "firstName": "Lisa",
            "lastName": "Rodriguez",
            "notes": "Roommate from sophomore year. Now works as a nurse in Seattle.",
            "contactInfo": {
                "email": "lisa.rodriguez@hospital.org",
                "phone": "+1-555-0501",
                "address": "888 Pine Street, Seattle, WA 98101"
            }
        }
    }'
    '{
        "nickName": "Tom",
        "group": "neighbors",
        "details": {
            "firstName": "Thomas",
            "lastName": "Anderson",
            "notes": "Lives next door. Has two dogs and enjoys running in the mornings.",
            "contactInfo": {
                "email": "tom.anderson@email.com",
                "phone": "+1-555-0601",
                "address": "125 Maple Street, Springfield, IL 62701"
            }
        }
    }'
    '{
        "nickName": "Priya",
        "group": "work colleagues",
        "details": {
            "firstName": "Priya",
            "lastName": "Patel",
            "notes": "UX designer. Very creative and always has great insights.",
            "contactInfo": {
                "email": "priya.patel@company.com",
                "phone": "+1-555-0302",
                "address": "321 Business Blvd, New York, NY 10001"
            }
        }
    }'
    '{
        "nickName": "Marcus",
        "group": "acquaintances",
        "details": {
            "firstName": "Marcus",
            "lastName": "Thompson",
            "notes": "Met at a conference last year. Works in marketing at a startup.",
            "contactInfo": {
                "email": "marcus.t@startup.co",
                "phone": "+1-555-0701",
                "address": "999 Innovation Way, Austin, TX 78701"
            }
        }
    }'
)

for contact in "${contacts[@]}"; do
    nickname=$(echo "$contact" | grep -o '"nickName": *"[^"]*' | cut -d'"' -f4)
    make_api_call "POST" "$RECONNECT_URL/contacts" "$contact" "Creating contact: $nickname"
done

# Step 4: Create Interactions
echo -e "\n${BLUE}💬 Step 4: Creating interactions...${NC}"

# Get current timestamp in milliseconds
current_time=$(date +%s)000

# Calculate timestamps for various dates
one_day_ago=$((current_time - 86400000))      # 1 day ago
three_days_ago=$((current_time - 259200000))  # 3 days ago
one_week_ago=$((current_time - 604800000))    # 1 week ago
two_weeks_ago=$((current_time - 1209600000))  # 2 weeks ago
one_month_ago=$((current_time - 2629746000))  # 30 days ago

interactions=(
    # Recent interactions
    '{
        "contact": "mom",
        "timeStamp": "'$one_day_ago'",
        "notes": "Called to check in. She told me about her new garden project and invited me for Sunday dinner.",
        "interactionDetails": {
            "selfInitiated": true,
            "type": "AUDIO_CALL"
        }
    }'
    '{
        "contact": "alex",
        "timeStamp": "'$three_days_ago'",
        "notes": "Had coffee and caught up on work. She got promoted to senior engineer!",
        "interactionDetails": {
            "selfInitiated": false,
            "type": "IN_PERSON"
        }
    }'
    '{
        "contact": "jake",
        "timeStamp": "'$one_day_ago'",
        "notes": "Quick text exchange about weekend plans. Planning to meet up for board games.",
        "interactionDetails": {
            "selfInitiated": true,
            "type": "TEXT"
        }
    }'
    '{
        "contact": "emma",
        "timeStamp": "'$one_day_ago'",
        "notes": "Project status meeting. Discussed timeline for Q2 deliverables.",
        "interactionDetails": {
            "selfInitiated": false,
            "type": "VIDEO_CALL"
        }
    }'
    # Older interactions to show variety
    '{
        "contact": "dad",
        "timeStamp": "'$one_week_ago'",
        "notes": "He called to tell me about his fishing trip. Caught a big bass!",
        "interactionDetails": {
            "selfInitiated": false,
            "type": "AUDIO_CALL"
        }
    }'
    '{
        "contact": "dr. smith",
        "timeStamp": "'$two_weeks_ago'",
        "notes": "Career advice session. Discussed potential next steps and skill development.",
        "interactionDetails": {
            "selfInitiated": true,
            "type": "VIDEO_CALL"
        }
    }'
    '{
        "contact": "lisa",
        "timeStamp": "'$one_month_ago'",
        "notes": "Long overdue catch-up call. She loves her new job at the hospital.",
        "interactionDetails": {
            "selfInitiated": true,
            "type": "AUDIO_CALL"
        }
    }'
    '{
        "contact": "tom",
        "timeStamp": "'$one_week_ago'",
        "notes": "Bumped into him while getting mail. His dogs are doing well.",
        "interactionDetails": {
            "selfInitiated": false,
            "type": "IN_PERSON"
        }
    }'
    '{
        "contact": "priya",
        "timeStamp": "'$three_days_ago'",
        "notes": "Slack conversation about user research findings for the new feature.",
        "interactionDetails": {
            "selfInitiated": true,
            "type": "TEXT"
        }
    }'
    '{
        "contact": "marcus",
        "timeStamp": "'$one_month_ago'",
        "notes": "LinkedIn message exchange. He shared an interesting article about industry trends.",
        "interactionDetails": {
            "selfInitiated": false,
            "type": "SOCIAL_MEDIA"
        }
    }'
    # Additional interactions for better analytics
    '{
        "contact": "alex",
        "timeStamp": "'$one_week_ago'",
        "notes": "Video call to discuss her job interview preparation. Practiced coding questions.",
        "interactionDetails": {
            "selfInitiated": true,
            "type": "VIDEO_CALL"
        }
    }'
    '{
        "contact": "jake",
        "timeStamp": "'$two_weeks_ago'",
        "notes": "Game night at his place. Played Settlers of Catan until midnight.",
        "interactionDetails": {
            "selfInitiated": false,
            "type": "IN_PERSON"
        }
    }'
)

for interaction in "${interactions[@]}"; do
    contact_name=$(echo "$interaction" | grep -o '"contact": *"[^"]*' | cut -d'"' -f4)
    make_api_call "POST" "$RECONNECT_URL/interactions" "$interaction" "Creating interaction with: $contact_name"
done

# Step 5: Summary
echo -e "\n${GREEN}🎉 Dummy data loading complete!${NC}"
echo "=================================================="
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "✅ Created 7 groups (Family, Close Friends, Work Colleagues, etc.)"
echo -e "✅ Created 10 contacts with full details"
echo -e "✅ Created 12+ interactions across different time periods"
echo -e "✅ Data includes various interaction types: calls, texts, video, in-person, social media"
echo ""
echo -e "${YELLOW}🔧 What you can now test:${NC}"
echo -e "• View contacts in grid layout with avatars"
echo -e "• Filter contacts by groups using chips"
echo -e "• Search for contacts by name"
echo -e "• View detailed contact profiles with edit options"
echo -e "• Browse interaction history with timestamps"
echo -e "• See analytics with charts and health scores"
echo -e "• Test out-of-touch contact detection"
echo ""
echo -e "${GREEN}🚀 Your Reconnect app is now ready with realistic data!${NC}"
echo -e "${BLUE}💡 Tip: Some contacts haven't been contacted recently, so they'll appear in your 'Needs Attention' section${NC}"