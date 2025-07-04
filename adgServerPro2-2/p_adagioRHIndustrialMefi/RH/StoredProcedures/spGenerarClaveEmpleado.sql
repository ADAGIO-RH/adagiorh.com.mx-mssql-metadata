USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Generar las claves de los colaboradores.
** Autor			: Jose Rafael Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2021-08-20			Jose Roman			Se agrega configuración en configuraciones Generales para
										modificar la forma en que se generan las claves.
										0 = Generación normal en base a configuración de cada cliente. 
										1 = Número consecutivo entre todos los clientes de la base, pero respetando el prefijo.
2022-07-27          Javier Peña         Se modifica la función de calculo MAXClaveID                                        
***************************************************************************************************/


CREATE PROCEDURE [RH].[spGenerarClaveEmpleado] -- 4,0,1  
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
		, @ConfiguracionGeneracionClaves int
	;  
  

    select top 1 @ConfiguracionGeneracionClaves = cast(valor as int) from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'GenerarClaveEmpleado' 

	select @LongitudNoNomina = LongitudNoNomina  
			,@Prefijo = Prefijo    
	from RH.tblCatClientes  with(nolock)  
	where IDCliente = @IDCliente  
  
	IF((@LongitudNoNomina is null))  
	BEGIN  
		exec [App].[spObtenerError] 1, '0000003'  
		return;  
	END;  

	IF(isnull(@ConfiguracionGeneracionClaves,0) = 0) -- La generación de las claves de forma normal.
	BEGIN
  
		if (@MAXClaveID = 0)
		begin
            select @MAXClaveID = isnull(MAX(ISNULL(TRY_CAST(RIGHT(E.ClaveEmpleado,C.LongitudNoNomina-ISNULL(LEN(C.Prefijo),0))as int),0)),0)  
			from RH.tblEmpleados E   with(nolock)
				inner join RH.tblClienteEmpleado CE   with(nolock) 
					ON E.IDEmpleado = CE.IDEmpleado  
			--AND CE.FechaFin >= '9999-12-31'  
				Inner join RH.tblCatClientes C   with(nolock) 
					on CE.IDCliente = C.IDCliente  
			Where CE.IDCliente = @IDCliente  
				and E.ClaveEmpleado like coalesce(@Prefijo,'')+'%'  
            
			Set @MAXClaveID = @MAXClaveID + 1  
		end;
	END
	
	IF(isnull(@ConfiguracionGeneracionClaves,0) = 1)
	BEGIN
		if (@MAXClaveID = 0)
		begin  
            select @MAXClaveID = isnull(MAX(ISNULL(TRY_CAST(RIGHT(E.ClaveEmpleado,C.LongitudNoNomina-ISNULL(LEN(C.Prefijo),0))as int),0)),0)  
			from RH.tblEmpleadosMaster E  with(nolock)   
				Inner join RH.tblCatClientes C   with(nolock)
					on e.IDCliente = C.IDCliente  
			Set @MAXClaveID = @MAXClaveID + 1  
		end;
	END

	set @CalcularStringClave = @LongitudNoNomina - LEN(isnull(@Prefijo,''))  
   
	SELECT @ClaveEmpleado = isnull(@Prefijo,'')+REPLICATE('0',@CalcularStringClave - LEN(RTRIM(cast( @MAXClaveID as varchar)))) + cast( @MAXClaveID as Varchar)  
  
	Select @ClaveEmpleado  
END
GO
