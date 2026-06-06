-- GOA MOMENTS SQL SCHEMA
-- Run this script in your Supabase SQL Editor to set up the database structure.

-- Enable UUID generation
create extension if not exists "uuid-ossp";

-- Create update_at trigger function
create or replace function update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

-- 1. MEMBERSHIP PLANS TABLE
create table membership_plans (
    id text primary key, -- e.g. 'diamond', 'platinum', 'gold'
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    status text default 'active' not null, -- 'active', 'inactive'
    name text not null,
    description text,
    price text
);

create trigger update_membership_plans_modtime
    before update on membership_plans
    for each row execute procedure update_updated_at_column();

-- 2. MEMBERS TABLE
create table members (
    id text primary key, -- The Membership ID (e.g., 'GM-777-GOLD', 'GM-111-DIAMOND')
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    status text default 'pending' not null, -- 'pending', 'active', 'suspended'
    name text not null,
    email text unique not null,
    phone text not null,
    city text,
    plan_id text references membership_plans(id) on delete set null,
    activation_date timestamp with time zone
);

create trigger update_members_modtime
    before update on members
    for each row execute procedure update_updated_at_column();

-- 3. DEVICE REGISTRATIONS TABLE (One member can only have one active device registration)
create table device_registrations (
    id uuid primary key default gen_random_uuid(),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    status text default 'active' not null, -- 'active', 'inactive'
    member_id text references members(id) on delete cascade unique, -- unique ensures 1 active device per member
    device_id text not null,
    device_model text not null,
    activation_location text not null,
    activation_timestamp timestamp with time zone default now() not null
);

create trigger update_device_registrations_modtime
    before update on device_registrations
    for each row execute procedure update_updated_at_column();

-- 4. ACTIVATION LOGS TABLE
create table activation_logs (
    id uuid primary key default gen_random_uuid(),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    status text not null, -- 'success', 'failed_location', 'failed_device', 'duplicate_attempt'
    membership_id text not null,
    member_name text not null,
    device text not null,
    location text not null,
    activation_time timestamp with time zone default now() not null
);

create trigger update_activation_logs_modtime
    before update on activation_logs
    for each row execute procedure update_updated_at_column();

-- 5. BENEFITS TABLE
create table benefits (
    id uuid primary key default gen_random_uuid(),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    status text default 'active' not null, -- 'active', 'inactive'
    title text not null,
    description text not null,
    category text not null, -- 'Hotels', 'Restaurants', 'Nightlife', 'Experiences', 'VIP Access'
    image_url text,
    priority integer default 0
);

create trigger update_benefits_modtime
    before update on benefits
    for each row execute procedure update_updated_at_column();

-- 6. SUPPORT TICKETS TABLE
create table support_tickets (
    id uuid primary key default gen_random_uuid(),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    status text default 'open' not null, -- 'open', 'in_progress', 'resolved'
    member_id text references members(id) on delete cascade,
    subject text not null,
    message text not null,
    contact_method text not null -- 'WhatsApp', 'Email', 'Call'
);

create trigger update_support_tickets_modtime
    before update on support_tickets
    for each row execute procedure update_updated_at_column();

-- 7. NOTIFICATIONS TABLE
create table notifications (
    id uuid primary key default gen_random_uuid(),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    status text default 'sent' not null, -- 'sent', 'read', 'archived'
    member_id text references members(id) on delete cascade, -- Null if global announcement
    title text not null,
    message text not null
);

create trigger update_notifications_modtime
    before update on notifications
    for each row execute procedure update_updated_at_column();

-- 8. SERVICE PARTNERS TABLE
create table service_partners (
    id uuid primary key default gen_random_uuid(),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    status text default 'active' not null, -- 'active', 'inactive'
    name text not null,
    category text not null, -- 'Hotel', 'Restaurant', 'Spa', 'Yacht'
    location text not null,
    discount_offer text not null
);

create trigger update_service_partners_modtime
    before update on service_partners
    for each row execute procedure update_updated_at_column();

-- INDEXES FOR FAST LOOKUPS
create index idx_members_email on members(email);
create index idx_members_status on members(status);
create index idx_device_registrations_member_id on device_registrations(member_id);
create index idx_device_registrations_device_id on device_registrations(device_id);
create index idx_activation_logs_membership_id on activation_logs(membership_id);
create index idx_benefits_category on benefits(category);
create index idx_support_tickets_member_id on support_tickets(member_id);
create index idx_notifications_member_id on notifications(member_id);

-- SEED DATA (MOCK DATA FOR TESTING)
-- Membership Plans
insert into membership_plans (id, name, description, price) values
('diamond', 'Diamond Membership', 'Ultra-exclusive access to premium Goa experiences, yacht charters, and 24/7 concierge.', '₹1,50,000/yr'),
('platinum', 'Platinum Membership', 'Elite entry to Goa top retreats, VIP club seating, and private dining events.', '₹90,000/yr'),
('gold', 'Gold Membership', 'Curated experiences, luxury dining discounts, and boutique hotel stays.', '₹50,000/yr');

-- Members
insert into members (id, name, email, phone, city, plan_id, status) values
('GM-777-GOLD', 'Aryan Sharma', 'aryan@example.com', '+919876543210', 'Mumbai', 'gold', 'pending'),
('GM-111-DIAMOND', 'Priya Patel', 'priya@example.com', '+919999999999', 'Delhi', 'diamond', 'pending'),
('GM-222-PLATINUM', 'Kabir Mehta', 'kabir@example.com', '+918888888888', 'Goa', 'platinum', 'pending');

-- Benefits
insert into benefits (title, description, category, image_url, priority) values
('W Goa - Villa Stay', 'Complimentary 2-night stay in a private luxury chalet with plunge pool and panoramic beach views.', 'Hotels', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&q=80&w=800', 1),
('Gunpowder Restaurant', 'Priority table reservations and a complimentary premium chef-tasting menu for two.', 'Restaurants', 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&q=80&w=800', 2),
('Club Cubana VIP Lounge', 'Direct queue bypass and access to the private VIP balcony with complimentary premium bottles.', 'Nightlife', 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&q=80&w=800', 3),
('Private Yacht Charter', 'Exclusive 4-hour sunset cruise along the Mandovi river with champagne and gourmet catering.', 'Experiences', 'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?auto=format&fit=crop&q=80&w=800', 4),
('Taj Exotica Beach Dinner', 'Candlelit oceanfront dinner with dedicated butler service and customized seafood platter.', 'VIP Access', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=800', 5);

-- Service Partners
insert into service_partners (name, category, location, discount_offer) values
('W Goa', 'Hotel', 'Vagator', '20% off Spa and Food & Beverage'),
('Thalassa', 'Restaurant', 'Siolim', 'Complimentary welcome drinks & premium table bookings'),
('Lilliput', 'Nightlife', 'Anjuna', 'Free entry & 15% off total bill'),
('Goa Yacht Club', 'Yacht', 'Panaji', '10% off private charter booking');
