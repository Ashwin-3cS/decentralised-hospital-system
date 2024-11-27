/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "assets.aceternity.com",
        port: "", // leave it blank if there's no specific port
        pathname: "/**", // allows all paths under this domain
      },
    ],
  },
};

export default nextConfig;
