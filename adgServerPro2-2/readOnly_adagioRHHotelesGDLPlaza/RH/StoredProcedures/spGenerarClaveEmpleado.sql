USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spGenerarClaveEmpleado] -- 1,1  
(  
 @IDCliente int,  
 @MAXClaveID int = 0,  
 @IDUsuario int  
)  
AS  
BEGIN  
  
	DECLARE @LongitudNoNomina int,  
		@Prefijo varchar(10),  
		--@MAXClaveID int,  
		@CalcularStringClave int,  
		@ClaveEmpleado Varchar(20)  
	;  
  
	select @LongitudNoNomina = LongitudNoNomina  
			,@Prefijo = Prefijo    
	from RH.tblCatClientes  
	where IDCliente = @IDCliente  
  
	IF((@LongitudNoNomina is null))  
	BEGIN  
		exec [App].[spObtenerError] 1, '0000003'  
		return;  
	END;  
  
	if (@MAXClaveID = 0)
	begin
		select @MAXClaveID = isnull(MAX(cast(REPLACE(E.ClaveEmpleado, isnull(C.Prefijo,''),'') as int)),0)  
		from RH.tblEmpleados E  
			inner join RH.tblClienteEmpleado CE  
				ON E.IDEmpleado = CE.IDEmpleado  
		--AND CE.FechaFin >= '9999-12-31'  
			Inner join RH.tblCatClientes C  
				on CE.IDCliente = C.IDCliente  
		Where CE.IDCliente = @IDCliente  
			and E.ClaveEmpleado like coalesce(@Prefijo,'')+'%'  

		Set @MAXClaveID = @MAXClaveID + 1  
	end;

	set @CalcularStringClave = @LongitudNoNomina - LEN(isnull(@Prefijo,''))  
   
	SELECT @ClaveEmpleado = isnull(@Prefijo,'')+REPLICATE('0',@CalcularStringClave - LEN(RTRIM(cast( @MAXClaveID as varchar)))) + cast( @MAXClaveID as Varchar)  
  
	Select @ClaveEmpleado  
END
GO
