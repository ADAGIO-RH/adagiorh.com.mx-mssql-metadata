USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblFamiliaresEmpleado](
	[IDFamiliarEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoFamiliar] [int] NOT NULL,
	[PrimerNombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[SegundoNombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Paterno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Materno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaNacimiento] [date] NOT NULL,
	[EsBeneficiario] [bit] NOT NULL,
	[Sexo] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHtblFamiliaresEmpleado_IDFamiliarEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDFamiliarEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblFamiliaresEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatTipoFamiliar_RHtblFamiliaresEmpleado_IDTipoFamiliar] FOREIGN KEY([IDTipoFamiliar])
REFERENCES [RH].[tblCatTipoFamiliar] ([IDTipoFamiliar])
GO
ALTER TABLE [RH].[tblFamiliaresEmpleado] CHECK CONSTRAINT [FK_RHtblCatTipoFamiliar_RHtblFamiliaresEmpleado_IDTipoFamiliar]
GO
