USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spGenerarCuenta](
    @Nombre varchar(255)
    ,@Apellido varchar(255)
) as
begin
    declare @Cuenta varchar(50)
		 ,@Random int = 0;


    set @Apellido = replace(@Apellido,' ','')
    set @Cuenta= rtrim(ltrim(LOWER(isnull(@Nombre,''))))
		  +''+rtrim(ltrim(LOWER(isnull(@Apellido,''))));

    while exists (select 1 
		  from Seguridad.tblUsuarios 
		  where Cuenta=@Cuenta)
    begin
	   SELECT @Random=ROUND(((999 - 1 -1) * RAND() + 1), 0);

	   set @Cuenta=@Cuenta+''+cast(@Random as varchar);
    end;

    select @Cuenta as Cuenta
end;
GO
