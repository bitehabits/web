<script lang="ts">
	import Logo from '$lib/assets/bite-habits-logo-trans.png';
	import { User } from '@lucide/svelte';
	import { getUser } from '$lib/context/user-context';
	import { page } from '$app/state';
	import { enhance } from '$app/forms';

	let pathname = $derived(page.url.pathname);

	const middleRoutes = [
		{
			label: 'Oppskrifter',
			href: '/oppskrifter'
		},
		{
			label: 'Kjøleskap',
			href: '/kjoleskap'
		}
	];

	let deg = $state(0);
	let shouldRotate = $state(false);

	const handleLogoFocus = async () => {
		shouldRotate = true;

		while (shouldRotate) {
			deg += 1;
			if (deg >= 360) deg = 0;
			await new Promise((resolve) => setTimeout(resolve, 10));
		}
	};

	const stopRotation = () => {
		shouldRotate = false;
	};

	let user = getUser();
</script>

<header class="relative mx-auto mb-10 flex w-full max-w-4xl items-center justify-between p-6">
	<div>
		<a href="/"
			><img
				src={Logo}
				class="size-14"
				style={`transform: rotate(${deg}deg);`}
				alt="BiteHabits logo"
				onmouseover={handleLogoFocus}
				onfocus={handleLogoFocus}
				onmouseleave={stopRotation}
				onblur={stopRotation}
			/></a
		>
	</div>

	{#if $user}
		<menu class="absolute left-1/2 flex -translate-x-1/2 flex-row items-center gap-5">
			{#each middleRoutes as route (route.label)}
				{@const isActive = pathname === route.href}
				<li>
					<a
						class={`${isActive ? 'text-gray-900 underline' : 'text-gray-600'} transition-colors hover:text-gray-900`}
						href={route.href}>{route.label}</a
					>
				</li>
			{/each}
		</menu>
	{/if}

	<menu class="flex items-center gap-4 text-lg font-medium">
		{#if $user}
			<li>
				<a href="/profil">
					<User class="size-6 text-gray-600" />
				</a>
			</li>
			<li>
				<form action="/logg-ut" method="post" use:enhance>
					<button class="text-gray-600 transition-colors hover:text-gray-900">Logg ut</button>
				</form>
			</li>
		{/if}
		{#if !$user}
			<li>
				<a class="text-gray-600 transition-colors hover:text-gray-900" href="/logg-inn">Logg inn</a>
			</li>
			<li>
				<a class="text-gray-600 transition-colors hover:text-gray-900" href="/registrer-deg"
					>Registrer</a
				>
			</li>
		{/if}
	</menu>
</header>
