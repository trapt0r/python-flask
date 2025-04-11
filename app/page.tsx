"use client";

import React from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar } from "@/components/ui/avatar";
import { BellIcon, SunIcon } from "lucide-react";

export default function DeveloperPortal() {
  return (
    <div className="flex h-screen w-screen">
      {/* Sidebar */}
      <aside className="w-64 bg-gray-100 border-r p-4 flex flex-col space-y-4">
        <h1 className="text-xl font-bold">Dev Portal</h1>
        <nav className="flex flex-col space-y-2">
          <a href="/" className="hover:underline">Home</a>
          <a href="/tooling" className="hover:underline">Tooling Catalog</a>
          <a href="/languages" className="hover:underline">Languages & Runtimes</a>
          <a href="/requests" className="hover:underline">Request Center</a>
          <a href="/docs" className="hover:underline">Documentation</a>
        </nav>
      </aside>

      {/* Main content */}
      <main className="flex-1 p-6 bg-white overflow-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <Input placeholder="Search..." className="w-1/2" />
          <div className="flex items-center space-x-4">
            <SunIcon className="w-5 h-5" />
            <BellIcon className="w-5 h-5" />
            <Avatar />
          </div>
        </div>

        {/* Welcome Banner */}
        <h2 className="text-2xl font-semibold mb-4">Good Morning, Brent</h2>

        {/* News & Hot Topics */}
        <Card className="mb-4">
          <CardContent>
            <h3 className="text-lg font-medium mb-2">Latest News</h3>
            <ul className="list-disc list-inside">
              <li>Python 3.12 now available</li>
              <li>Java SDK updates coming next week</li>
              <li>Internal Hackathon in 2 weeks</li>
            </ul>
          </CardContent>
        </Card>

        {/* Ticker */}
        <div className="bg-yellow-100 p-2 mb-4 text-sm font-medium animate-pulse">
          Outage scheduled for Jenkins server on Saturday 8 PM EST
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          <Button variant="outline">Request Access</Button>
          <Button variant="outline">New Project Template</Button>
          <Button variant="outline">Submit Idea</Button>
          <Button variant="outline">Book Time With DevOps</Button>
        </div>

        {/* Tool Spotlight */}
        <Card>
          <CardContent>
            <h3 className="text-lg font-medium mb-2">Tool Spotlight: VS Code</h3>
            <p>
              Our most used IDE, now with remote support and better GitHub integration.
            </p>
          </CardContent>
        </Card>
      </main>
    </div>
  );
}
