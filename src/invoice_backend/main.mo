import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Map "mo:base/HashMap";
import Error "mo:base/Error";
import List "mo:base/List";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";

actor Invoice {
    type Track = {
        Subject : Text;
        Status : Text;
        MsgId : Text;
        To : Text;
        ApiKeyId : Text;
        Events : Text;
    };

    type Invoice = {
        Type : Text;
        InvoiceId : Text;
        VendorId : Text;
        MongoId : Text;
        CreationDate : Text;
        VendorEmail : Text;
        Action : Text;
        Ack : Bool;
        Finance : Bool;
        FinancingDetails : [Text];
        VendorEmailHash : Text;
        VendorMobileNumberHash : Text;
        VendorMobileNumber : Text;
        ClientFirstName : Text;
        ClientLastName : Text;
        VendorName : Text;
        ClientEmail : Text;
        ClientMobileNumber : Text;
        Currency : Text;
        FundReception : Text;
        Lines : Text;
        NetAmt : Text;
        Paid : Bool;
        Rejected : Bool;
        Voided : Bool;
        SentInvoiceDeleted : Bool;
        ReceivedInvoiceDeleted : Bool;
        TimeStamp : Int;
        PreviousInvoiceHash : Text;
        TxnHash : Text;
        DueDate : Text;
        DeleteComments : Text;
        PaymentConfirmation : Bool;
        Tracking : Track;
    };
    type QueryResult = {
        Key : Text;
        Record : ?Invoice;
    };
    // type History = {
    //     Record : ;
    // };

    private stable var mapEntries : [(Text, Invoice)] = [];
    var map = Map.HashMap<Text, Invoice>(0, Text.equal, Text.hash);
    private stable var historyEntries : [(Text, [Invoice])] = [];
    var history = Map.HashMap<Text, Buffer.Buffer<Invoice>>(0, Text.equal, Text.hash);

    public func CreateInvoice(mongoid : Text, invoiceid : Text, creationDate : Text, vendoremail : Text, vendormobilenumber : Text, clientFname : Text, clientLname : Text, vendorname : Text, clientemail : Text, clientmobilenumber : Text, currency : Text, fundreception : Text, lines : Text, netAMT : Text, txnHash : Text, vendoremailhash : Text, vendormobileHash : Text, action : Text, dueDate : Text, vendorId : Text,Times:Int) : async Text {
        let array = Buffer.fromArray<Text>([]);

        switch (map.get(mongoid)) {
            case (null) {
                let invoice : Invoice = {
                    Type = "Invoice";
                    InvoiceId = invoiceid;
                    VendorId = vendorId;
                    MongoId = mongoid;
                    CreationDate = creationDate;
                    VendorEmail = vendoremail;
                    Action = action;
                    Ack = false;
                    Finance = false;
                    FinancingDetails = Buffer.toArray(array);
                    VendorEmailHash = vendoremailhash;
                    VendorMobileNumberHash = vendormobileHash;
                    VendorMobileNumber = vendormobilenumber;
                    ClientFirstName = clientFname;
                    ClientLastName = clientLname;
                    VendorName = vendorname;
                    ClientEmail = clientemail;
                    ClientMobileNumber = clientmobilenumber;
                    Currency = currency;
                    FundReception = fundreception;
                    Lines = lines;
                    NetAmt = netAMT;
                    Paid = false;
                    Rejected = false;
                    Voided = false;
                    SentInvoiceDeleted = false;
                    ReceivedInvoiceDeleted = false;
                    TimeStamp = Times;
                    PreviousInvoiceHash = "";
                    TxnHash = txnHash;
                    DueDate = dueDate;
                    DeleteComments = "";
                    PaymentConfirmation = false;
                    Tracking = {
                        Subject = "";
                        Status = "";
                        MsgId = "";
                        To = "";
                        ApiKeyId = "";
                        Events = "";
                    };
                };
                map.put(mongoid, invoice);
                var a = Buffer.Buffer<Invoice>(0);
                a.add(invoice);
                history.put(mongoid, a);
                return "invoice created";
            };
            case (?value) {
                return "invoice allready exist";
            };
        };

    };

    public query func QueryInvoice(id : Text) : async ?Invoice {
        map.get(id);
    };

    public func AckInvoice(mongoId : Text, action : Text, txnHash : Text,Times:Int) : async Text {
        switch (map.get(mongoId)) {
            case (?value) {
                if (value.Ack == false and value.Finance == false and value.Paid == false and value.Rejected == false and value.Voided == false and value.PaymentConfirmation == false) {
                    let updatedInvoice = {
                        value with
                        Ack = true;
                        TimeStamp = Times;
                        Action = action;
                        PreviousInvoiceHash = value.TxnHash;
                        TxnHash = txnHash;
                    };
                    let updatedMap = map.replace(mongoId, updatedInvoice);
                    switch (history.get(mongoId)) {
                        case (?x) {
                            x.add(updatedInvoice);
                            let res = history.put(mongoId, x);
                        };
                        case (null) {};
                    };
                    return "invoice acknowledge";
                } else {
                    return Text.concat("request falied,current invoice status = ", value.Action);
                };
            };
            case (null) {
                return "invoice not exist!";
            };
        };
    };

    public func PaidInvoice(mongoId : Text, action : Text, txnHash : Text,Times:Int) : async Text {
        switch (map.get(mongoId)) {
            case (?value) {
                if (value.Finance == false and value.Paid == false and value.Rejected == false and value.Voided == false and value.PaymentConfirmation == false) {
                    let updatedInvoice = {
                        value with
                        Ack = true;
                        Paid = true;
                        TimeStamp = Times;
                        Action = action;
                        PreviousInvoiceHash = value.TxnHash;
                        TxnHash = txnHash;
                    };
                    let updatedMap = map.replace(mongoId, updatedInvoice);
                    switch (history.get(mongoId)) {
                        case (?x) {
                            x.add(updatedInvoice);
                            let res = history.put(mongoId, x);
                        };
                        case (null) {};
                    };
                    return "invoice paid";
                } else {
                    return Text.concat("request falied,current invoice status = ", value.Action);
                };
            };
            case (null) {
                return "invoice not exist!";
            };
        };
    };

    public func RejectInvoice(mongoId : Text, action : Text, txnHash : Text,Times:Int) : async Text {
        switch (map.get(mongoId)) {
            case (?value) {
                if (value.Finance == false and value.Paid == false and value.Rejected == false and value.Voided == false and value.PaymentConfirmation == false) {
                    let updatedInvoice = {
                        value with
                        Rejected = true;
                        TimeStamp = Times;
                        Action = action;
                        PreviousInvoiceHash = value.TxnHash;
                        TxnHash = txnHash;
                    };
                    let updatedMap = map.replace(mongoId, updatedInvoice);
                    switch (history.get(mongoId)) {
                        case (?x) {
                            x.add(updatedInvoice);
                            let res = history.put(mongoId, x);
                        };
                        case (null) {};
                    };
                    return "invoice rejected";
                } else {
                    return Text.concat("request falied,current invoice status = ", value.Action);
                };
            };
            case (null) {
                return "invoice not exist!";
            };
        };
    };

    public func VoidedInvoice(mongoId : Text, action : Text, txnHash : Text,Times:Int) : async Text {
        switch (map.get(mongoId)) {
            case (?value) {
                if (value.Finance == false and value.Paid == false and value.Rejected == false and value.Voided == false and value.PaymentConfirmation == false) {
                    let updatedInvoice = {
                        value with
                        Voided = true;
                        TimeStamp = Times;
                        Action = action;
                        PreviousInvoiceHash = value.TxnHash;
                        TxnHash = txnHash;
                    };
                    let updatedMap = map.replace(mongoId, updatedInvoice);
                    switch (history.get(mongoId)) {
                        case (?x) {
                            x.add(updatedInvoice);
                            let res = history.put(mongoId, x);
                        };
                        case (null) {};
                    };
                    return "invoice voided";
                } else {
                    return Text.concat("request falied,current invoice status = ", value.Action);
                };
            };
            case (null) {
                return "invoice not exist!";
            };
        };
    };

    public func PaymentConfirmationInvoice(mongoId : Text, action : Text, txnHash : Text,Times:Int) : async Text {
        switch (map.get(mongoId)) {
            case (?value) {
                if (value.Ack == true and value.Rejected == false and value.Voided == false and value.PaymentConfirmation == false) {
                    let updatedInvoice = {
                        value with
                        Paid = true;
                        PaymentConfirmation = true;
                        TimeStamp = Times;
                        Action = action;
                        PreviousInvoiceHash = value.TxnHash;
                        TxnHash = txnHash;
                    };
                    let updatedMap = map.replace(mongoId, updatedInvoice);
                    switch (history.get(mongoId)) {
                        case (?x) {
                            x.add(updatedInvoice);
                            let res = history.put(mongoId, x);
                        };
                        case (null) {};
                    };
                    return "invoice payment confirmed";
                } else {
                    return Text.concat("request falied,current invoice status = ", value.Action);
                };
            };
            case (null) {
                return "invoice not exist!";
            };
        };
    };
    public func UpdateInvoiceTracking(mongoId : Text, subject : Text, status : Text, msgid : Text, apiKeyID : Text, events : Text, To : Text) : async Text {
        switch (map.get(mongoId)) {
            case (?value) {
                let updatedInvoice = {
                    value with
                    Tracking = {
                        Subject = subject;
                        Status = status;
                        MsgId = msgid;
                        To = To;
                        ApiKeyId = apiKeyID;
                        Events = events;
                    };
                };
                let updatedMap = map.replace(mongoId, updatedInvoice);
                let res = switch (history.get(mongoId)) {
                    case (?x) {
                        x.add(updatedInvoice);
                        let res = history.put(mongoId, x);

                    };
                    case (null) {};
                };
                return "invoice tracking updated";

            };
            case (null) {
                return "invoice not exist!";
            };
        };
    };

    public query func QueryAllInvoices() : async [(Text, Invoice)] {
        var tempArray : [(Text, Invoice)] = [];
        tempArray := Iter.toArray(map.entries());

        return tempArray;
    };

    public query func QueryAllInvoicesHistory(mongoId : Text) : async [Invoice] {
        switch (history.get(mongoId)) {
            case (?x) {
                return Buffer.toArray<Invoice>(x);
            };
            case (null) {
                return [];
            };
        };

    };

    public query func QueryInvoicesByVendorEmailHash(emailHash : Text) : async [Invoice] {
        var b = Buffer.Buffer<Invoice>(2);

        // var buffer: Buffer.T<Invoice> = Buffer.empty<Invoice>();
        for (invoice in map.entries()) {
            if (invoice.1.VendorEmailHash == emailHash) {
                b.add(invoice.1);
            };
        };
        return Buffer.toArray<Invoice>(b);

    };
    public query func QueryInvoicesByVendorMobileNumber(vendorNumber : Text) : async [Invoice] {
        var b = Buffer.Buffer<Invoice>(2);

        for (invoice in map.entries()) {
            if (invoice.1.VendorMobileNumberHash == vendorNumber) {
                b.add(invoice.1);
            };
        };

        return Buffer.toArray<Invoice>(b);
    };

    public func DeleteInvoice(mongoId : Text, sentDelete : Bool, recieveDelete : Bool, deleteComments : Text, txnHash : Text,Times:Int) : async Text {

        let res : ?Invoice = map.get(mongoId);

        switch (res) {
            case (null) {};
            case (_) {

                ignore map.remove(mongoId);
                return "Invoice deleted";
            };
        };

        switch (map.get(mongoId)) {
            case (?value) {
                if (true) {
                    let updatedInvoice = {
                        value with
                        SentInvoiceDeleted = sentDelete;
                        ReceivedInvoiceDeleted = recieveDelete;
                        DeleteComments = deleteComments;
                        TimeStamp = Times;
                        PreviousInvoiceHash = value.TxnHash;
                        TxnHash = txnHash;
                    };
                    let updatedMap = map.replace(mongoId, updatedInvoice);

                    return "invoice deleted";
                } else {
                    return Text.concat("request falied,current invoice status = ", value.Action);
                };
            };
            case (null) {
                return "invoice not exist!";
            };
        };
    };

    // create finance invoice
    public func FinanceInvoice(mongoId : Text, financeid : Text, action : Text, txnHash : Text,Times:Int) : async Text {
        switch (map.get(mongoId)) {
            case (?value) {
                if (value.Ack == true and value.Finance == false and value.Paid == false and value.Rejected == false and value.Voided == false and value.PaymentConfirmation == false) {
                    let array = [financeid];
                    let updatedInvoice = {
                        value with
                        Finance = true;
                        TimeStamp = Times;
                        Action = action;
                        FinancingDetails = array;
                        PreviousInvoiceHash = value.TxnHash;
                        TxnHash = txnHash;
                    };
                    let updatedMap = map.replace(mongoId, updatedInvoice);
                    switch (history.get(mongoId)) {
                        case (?x) {
                            x.add(updatedInvoice);
                            let res = history.put(mongoId, x);
                        };
                        case (null) {

                        };
                    };
                    return "invoice finance request initiated";
                } else if (value.Ack == true and value.Finance == true and value.Paid == false and value.Rejected == false and value.Voided == false and value.PaymentConfirmation == false) {
                    let array = Buffer.fromArray<Text>(value.FinancingDetails);
                    array.add(financeid);
                    let updatedInvoice = {
                        value with
                        Finance = true;
                        TimeStamp = Time.now();
                        Action = action;
                        FinancingDetails = Buffer.toArray<Text>(array);
                        PreviousInvoiceHash = value.TxnHash;
                        TxnHash = txnHash;
                    };
                    let updatedMap = map.put(mongoId, updatedInvoice);
                    switch (history.get(mongoId)) {
                        case (?x) {
                            x.add(updatedInvoice);
                            let res = history.put(mongoId, x);
                        };
                        case (null) {};
                    };
                    return "invoice finance request initiated";
                } else {
                    return Text.concat("request falied,current invoice status = ", value.Action);
                };
            };
            case (null) {
                return "invoice not exist!";
            };
        };
    };

    system func preupgrade() {
        mapEntries := Iter.toArray(map.entries());
        let Entries = Iter.toArray(history.entries());
        var data = Map.HashMap<Text, [Invoice]>(0, Text.equal, Text.hash);

        for (x in Iter.fromArray(Entries)) {
            data.put(x.0, Buffer.toArray<Invoice>(x.1));
        };
        historyEntries := Iter.toArray(data.entries());

    };
    system func postupgrade() {
        map := HashMap.fromIter<Text, Invoice>(mapEntries.vals(), 1, Text.equal, Text.hash);
        let his = HashMap.fromIter<Text, [Invoice]>(historyEntries.vals(), 1, Text.equal, Text.hash);
        let Entries = Iter.toArray(his.entries());
        for (x in Iter.fromArray(Entries)) {
            history.put(x.0, Buffer.fromArray<Invoice>(x.1));
        };

    };
};
