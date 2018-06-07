#include "activemasternode.h"
#include "sensus.h"
#include "governance.h"
#include "governance-vote.h"
#include "governance-classes.h"
#include "init.h"
#include "main.h"
#include "masternode.h"
#include "masternode-sync.h"
#include "masternodeconfig.h"
#include "masternodeman.h"
#include "rpcserver.h"
#include "util.h"
#include "utilmoneystr.h"

#include <boost/lexical_cast.hpp>

UniValue gobject(const UniValue& params, bool fHelp)
{
    std::string strCommand;
    if (params.size() >= 1)
        strCommand = params[0].get_str();

    if (fHelp  ||
        (strCommand != "vote-many" && strCommand != "vote-conf" && strCommand != "vote-alias" && strCommand != "prepare" && strCommand != "submit" && strCommand != "count" &&
         strCommand != "deserialize" && strCommand != "get" && strCommand != "getvotes" && strCommand != "getcurrentvotes" && strCommand != "list" && strCommand != "diff"))
        throw std::runtime_error(
                "gobject \"command\"...\n"
                "Manage governance objects\n"
                "\nAvailable commands:\n"
                "  prepare            - Prepare governance object by signing and creating tx\n"
                "  submit             - Submit governance object to network\n"
                "  deserialize        - Deserialize governance object from hex string to JSON\n"
                "  count              - Count governance objects and votes\n"
                "  get                - Get governance object by hash\n"
                "  getvotes           - Get all votes for a governance object hash (including old votes)\n"
                "  getcurrentvotes    - Get only current (tallying) votes for a governance object hash (does not include old votes)\n"
                "  list               - List governance objects (can be filtered by validity and/or object type)\n"
                "  diff               - List differences since last diff\n"
                "  vote-alias         - Vote on a governance object by masternode alias (using masternode.conf setup)\n"
                "  vote-conf          - Vote on a governance object by masternode configured in chainx.conf\n"
                "  vote-many          - Vote on a governance object by all masternodes (using masternode.conf setup)\n"
                );
