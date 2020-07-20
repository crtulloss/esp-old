#ifndef __HANDSHAKE_H__
#define __HANDSHAKE_H__

// Handshake request
class handshake_req_t
{
public:
    handshake_req_t(sc_module_name name) {} //: __req(std::string(name).append("_req")) { }

    sc_signal<bool> __req;
};

// Handshake acknowledge

class handshake_ack_t
{
public:
    handshake_ack_t(sc_module_name name) {} //: __ack(std::string(name).append("_ack")) { }

    sc_signal<bool> __ack;
};

// Interface

class handshake_t
{
public:

    // Constructor
    handshake_t(sc_module_name name) :
        __req(std::string(name).append("_req").c_str()),
        __ack(std::string(name).append("_ack").c_str()) {
    }

    void reset_req() {
        __req.__req.write(0);
    }

    void reset_ack() {
        __ack.__ack.write(0);
    }

#pragma design modulario<sync>
    void req() {
        do { wait(); }
        while (!__ack.__ack.read());
        __req.__req.write(1);
        wait();
        __req.__req.write(0);
    }

#pragma design modulario<sync>
    void ack() {
        wait();
        __ack.__ack.write(1);
        do{ wait(); }
        while (!__req.__req.read());
        __ack.__ack.write(0);
    }

    // Req and ack
    handshake_req_t __req;
    handshake_ack_t __ack;
};

#endif
