USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [AzureCognitiveServices].[spBuscarPersons](
	@PersonId varchar(255) = null,
	@IDEmpleado int = 0
) as
	select *
	from [AzureCognitiveServices].[tblPersons] with (nolock)
	where (PersonId = @PersonId or isnull(@PersonId,'') = '')
		and (IDEmpleado = @IDEmpleado or isnull(@IDEmpleado,0) = 0)
		and ( isnull(@PersonId,'') <> '' or isnull(@IDEmpleado,0) <> 0)
GO
