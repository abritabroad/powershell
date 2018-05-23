
$integrationTicketId = "610211-ZW1A111233-Buy"

$sqlInstance = "DAL2DEVPC354"

$sqlCommand = "USE Core_Tests; " + `

                "DECLARE @integrationTicketId VARCHAR(255) = '" + $integrationTicketId + "'; " + `

                "DELETE tblExternalTradeTicketData WHERE m_lExternalTradeTicket = (SELECT m_lObjectId FROM tblExternalTradeTicket WHERE m_sIntegrationTicketId = @integrationTicketId); " + `
                "DELETE tblExternalTradeTicketIdentifiers WHERE m_lExternalTradeTicket = (SELECT m_lObjectId FROM tblExternalTradeTicket WHERE m_sIntegrationTicketId = @integrationTicketId); " + `

                "DELETE tblExternalTradeTicket WHERE	m_sIntegrationTicketId = @integrationTicketId;"


"`r`nDeleting ExternalTradeTicket " + $integrationTicketId + "...`r`n"

Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $sqlCommand
